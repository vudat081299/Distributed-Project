////
////  UserControllerSM.swift
////  
////
////  Created by Vũ Quý Đạt  on 27/04/2021.
////
//
//import Vapor
//import MongoKitten
//import SMTPKitten
//
//struct UserControllerSM: RouteCollection {
//  func boot(routes: RoutesBuilder) throws {
//    let usersRoutes = routes.grouped("api", "users")
//    usersRoutes.post(use: signUp)
//    usersRoutes.get(use: getAllUsers)
//    usersRoutes.get("mailgun", use: sendEmail)
////    acronymsRoutes.get(":acronymID", use: getHandler)
////    acronymsRoutes.get("search", use: searchHandler)
////    acronymsRoutes.get("first", use: getFirstHandler)
////    acronymsRoutes.get("sorted", use: sortedHandler)
////    acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
////    acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
////
////    let tokenAuthMiddleware = Token.authenticator()
////    let guardAuthMiddleware = User.guardMiddleware()
////    let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
////    tokenAuthGroup.post(use: createHandler)
////    tokenAuthGroup.delete(":acronymID", use: deleteHandler)
////    tokenAuthGroup.put(":acronymID", use: updateHandler)
////    tokenAuthGroup.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
////    tokenAuthGroup.delete(":acronymID", "categories", ":categoryID", use: removeCategoriesHandler)
//  }
//
//    
//    func signUp(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        let signUpUserData = try req.content.decode(SignUpUser.self)
//        
//        let userProfile = UserProfileSM(
//            firstName: signUpUserData.firstName,
//            lastName: signUpUserData.lastName,
//            phoneNumber: signUpUserData.phoneNumber,
//            email: signUpUserData.email,
//            dob: signUpUserData.dob,
//            bio: signUpUserData.bio
//        )
//        let encryptedCredentialsSM = try EncryptedCredentialsSM(
//            username: signUpUserData.username,
//            password: signUpUserData.password
//        )
//        let user = UserSM(
//            _id: ObjectId(),
//            profile: userProfile,
//            credentials: encryptedCredentialsSM,
//            following: [],
//            followers: []
//        )
//        
//        return CoreEngineSM.createUser(user, inDatabase: req.mongoDBSM).transform(to: .created)
//    }
//    
//    func getAllUsers(_ req: Request) throws -> EventLoopFuture<[UserSMPublic]> {
//        return CoreEngineSM.findAllUsers(inDatabase: req.mongoDBSM).map { users in
//            return users.convertToPublicData()
//        }
//    }
//    
////    app.group(AuthenticationMiddleware()) { authenticated in
////        authenticated.on(.POST, "post", body: .collect(maxSize: "5mb")) { request -> EventLoopFuture<Response> in
////            listFileStructure(app.directory.publicDirectory)
//////            listDir(dir: app.directory.publicDirectory)
////
////            guard let accessToken = request.accessToken else {
////                return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
////            }
////
////            let createdPost = try request.content.decode(CreatePost.self)
////
////            let fileId: EventLoopFuture<ObjectId?>
////
////            if let file = createdPost.file, !file.isEmpty {
////                // Upload the attached file to GridFS
////                fileId = Repository.uploadFile(file, inDatabase: request.mongoDB).map { fileId in
////                    // This is needed to map the EventLoopFuture from `ObjectId` to `ObjectId?`
////                    return fileId
////                }
////            } else {
////                fileId = request.eventLoop.makeSucceededFuture(nil)
////            }
////
////            return fileId.flatMap { fileId in
////                let post = TimelinePost(
////                    _id: ObjectId(),
////                    text: createdPost.text,
////                    creationDate: Date(),
////                    fileId: fileId,
////                    creator: accessToken.subject
////                )
////
////                // Insert the newly created post into MongoDB
////                return Repository.createPost(post, inDatabase: request.mongoDB).map {
////                    return request.redirect(to: "/")
////                }
////            }
////        }
//    
//}
//
//struct CreateAcronymDatas: Content {
//  let short: String
//  let long: String
//}
