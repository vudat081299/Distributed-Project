//
//  AppSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor
import Leaf
import MongoKitten



// MARK: - App.
public func makeSocialMessApp() throws -> Application {
    let app = Application()

    // Use leaf view rendering
    // Views are stored in Resources/Views as .leaf files
    app.views.use(.leaf)
    
    guard let connectionString = Environment.get("MONGODB") else {
        fatalError("No MongoDB connection string is available in .env")
    }
    // connectionString should be MONGODB=mongodb://localhost:27017,localhost:27018,localhost:27019/server
    try app.initializeMongoDBSM(connectionString: connectionString)
    
    // Refer: /Users/vudat81299/Desktop/DiplomaProject/Server/Sources/App/routes.swift
    routeOfSocialMess(to: app) // Uncomment to run this service.
    
    try createTestingUsersSM(inDatabase: app.mongoDBSM)
    
    a() {
        print("11111")
    } c: {
        print("22222")
    }()
    return app
}



func a (b: @escaping () -> (), c: @escaping () -> ()) -> (() -> ()) {
    b()
    c()
    return { print("33333") }
}



// MARK: - Context.




// MARK: - Route.
func routeOfSocialMess(to app: Application) {
    app.post("login") { request -> EventLoopFuture<Response> in
        let credentials = try request.content.decode(CredentialsSM.self)
        
        return CoreEngine.findUser(
            byUsername: credentials.username,
            inDatabase: request.mongoDBSM
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
                
                let accessToken = AccessTokenSM(subject: user)
                let token = try request.application.jwtSM.sign(accessToken)
                
                let response = Response()
//                var cookie = HTTPCookies.Value(string: token)
//                cookie.expires = accessToken.expiration.value
//                response.cookies["server"] = cookie
                return request.eventLoop.makeSucceededFuture(response)
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
}
