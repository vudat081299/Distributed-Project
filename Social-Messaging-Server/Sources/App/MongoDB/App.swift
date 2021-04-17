//    Copyright (c) 2020 Razeware LLC
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without
//    restriction, including without limitation the rights to use,
//    copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom
//    the Software is furnished to do so, subject to the following
//    conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    Notwithstanding the foregoing, you may not use, copy, modify,
//    merge, publish, distribute, sublicense, create a derivative work,
//    and/or sell copies of the Software in any work that is designed,
//    intended, or marketed for pedagogical or instructional purposes
//    related to programming, coding, application development, or
//    information technology. Permission for such use, copying,
//    modification, merger, publication, distribution, sublicensing,
//    creation of derivative works, or sale is expressly withheld.
//
//    This project and source code may use libraries or frameworks
//    that are released under various Open-Source licenses. Use of
//    those libraries and frameworks are governed by their own
//    individual licenses.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//    DEALINGS IN THE SOFTWARE.

import Vapor
import Leaf
import MongoKitten

public func makeApp() throws -> Application {
    let app = Application()

    // Use leaf view rendering
    // Views are stored in Resources/Views as .leaf files
    app.views.use(.leaf)
    
    guard let connectionString = Environment.get("MONGODB") else {
        fatalError("No MongoDB connection string is available in .env")
    }
    // connectionString should be MONGODB=mongodb://localhost:27017,localhost:27018,localhost:27019/server
    try app.initializeMongoDB(connectionString: connectionString)
    
    // Refer: /Users/vudat81299/Desktop/DiplomaProject/Server/Sources/App/routes.swift
    registerRoutes(to: app) // Uncomment to run this service.
    
//    try createTestingUsers(inDatabase: app.mongoDB)
    
    return app
}

// MARK: - MongoDB.
struct HomepageContext: Codable {
    let posts: [ResolvedTimelinePost]
    let suggestedUsers: [UserMongoDB]
}

func registerRoutes(to app: Application) {
    app.get { request -> EventLoopFuture<View> in
        // Get the "server" cookie's string value
        guard let token = request.cookies["server"]?.string else {
            return request.view.render("MongoDB/loginMongoDB")
        }
        
        let accessToken = try request.application.jwt.verify(token, as: AccessToken.self)
        
        let posts = Repository.getFeed(
            forUser: accessToken.subject,
            inDatabase: request.mongoDB
        )
            
        let suggestedUsers = Repository.findSuggestedUsers(
            forUser: accessToken.subject,
            inDatabase: request.mongoDB
        )
            
        return posts.and(suggestedUsers).flatMap { posts, suggestedUsers in
            let context = HomepageContext(
                posts: posts,
                suggestedUsers: suggestedUsers
            )
            
            return request.view.render("MongoDB/indexMongoDB", context)
        }
    }
    
    app.post("login") { request -> EventLoopFuture<Response> in
        let credentials = try request.content.decode(Credentials.self)
        
        return Repository.findUser(
            byUsername: credentials.username,
            inDatabase: request.mongoDB
        ).flatMap { user -> EventLoopFuture<Response> in
            do {
                guard
                    let user = user,
                    try user.credentials.matchesPassword(credentials.password)
                else {
                    return request.view.render("MongoDB/loginMongoDB", [
                        "error": "Incorrect credentials"
                    ]).flatMap { view in
                        return view.encodeResponse(for: request)
                    }
                }
                
                let accessToken = AccessToken(subject: user)
                let token = try request.application.jwt.sign(accessToken)
                
                let response = request.redirect(to: "/")
                var cookie = HTTPCookies.Value(string: token)
                cookie.expires = accessToken.expiration.value
                response.cookies["server"] = cookie
                return request.eventLoop.makeSucceededFuture(response)
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    
    
    func listFileStructure (_ currentPath: String, _ path: String = "") {
        let fm = FileManager.default
        var fullPath = currentPath + path
        var a = fullPath.last!
        if a == Character("/") {
            
        } else {
            fullPath += "/"
        }
        print("---")
//        print(currentPath)
//        print(path)
        do {
            let items = try fm.contentsOfDirectory(atPath: fullPath)
            print("\(currentPath)\(path)")

            for item in items {
//                let isDir = (try URL(fileURLWithPath: fullPath).resourceValues(forKeys: [.isDirectoryKey])).isDirectory
                listFileStructure(fullPath, item)
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("\(fullPath)")
        }
    }
    
//    func listDir(dir: String) {
//        // Create a FileManager instance
//        let contentsOfCurrentWorkingDirectory = try?FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: dir), includingPropertiesForKeys: nil, options: [])
//
//        // process files
//        contentsOfCurrentWorkingDirectory?.forEach() { url in
//
//            contentsOfCurrentWorkingDirectory?.forEach() { url2 in
//                print(url2)
//            }
//        }
//    }
    
    app.group(AuthenticationMiddleware()) { authenticated in
        authenticated.on(.POST, "post", body: .collect(maxSize: "5mb")) { request -> EventLoopFuture<Response> in
            listFileStructure(app.directory.publicDirectory)
//            listDir(dir: app.directory.publicDirectory)
            
            guard let accessToken = request.accessToken else {
                return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
            }
            
            let createdPost = try request.content.decode(CreatePost.self)
            
            let fileId: EventLoopFuture<ObjectId?>
            
            if let file = createdPost.file, !file.isEmpty {
                // Upload the attached file to GridFS
                fileId = Repository.uploadFile(file, inDatabase: request.mongoDB).map { fileId in
                    // This is needed to map the EventLoopFuture from `ObjectId` to `ObjectId?`
                    return fileId
                }
            } else {
                fileId = request.eventLoop.makeSucceededFuture(nil)
            }
            
            return fileId.flatMap { fileId in
                let post = TimelinePost(
                    _id: ObjectId(),
                    text: createdPost.text,
                    creationDate: Date(),
                    fileId: fileId,
                    creator: accessToken.subject
                )
                
                // Insert the newly created post into MongoDB
                return Repository.createPost(post, inDatabase: request.mongoDB).map {
                    return request.redirect(to: "/")
                }
            }
        }
        
        authenticated.get("follow", ":userId") { request -> EventLoopFuture<Response> in
            guard
                let userId = request.parameters.get("userId", as: ObjectId.self),
                let accessToken = request.accessToken,
                userId != accessToken.subject
            else {
                return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
            }
            
            return Repository.findUser(byId: userId, inDatabase: request.mongoDB).flatMap { otherUser in
                return Repository.findUser(byId: accessToken.subject, inDatabase: request.mongoDB).flatMap { currentUser in
                    return Repository.followUser(otherUser, fromAccount: currentUser, inDatabase: request.mongoDB)
                }
            }.map { _ in
                return request.redirect(to: "/")
            }
        }
        
        authenticated.get("images", ":fileId") { request -> EventLoopFuture<Response> in
            guard let fileId = request.parameters.get("fileId", as: ObjectId.self) else {
                throw Abort(.notFound)
            }
            
            return Repository.readFile(byId: fileId, inDatabase: request.mongoDB).map { data in
                return Response(body: Response.Body(data: data))
            }
        }
    }
}
