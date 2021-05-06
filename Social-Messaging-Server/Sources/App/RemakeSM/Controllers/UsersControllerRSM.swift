//
//  UsersControllerRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor
import Fluent
import MongoKitten

struct UsersControllerRSM: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        
        // Test
        usersRoute.get("token", use: getAllToken)
        usersRoute.get("nosql", use: getAllUserData)
        usersRoute.get(":userId", use: getHandler)
        usersRoute.delete(":userId", "deleteUser", use: deleteHandler)
        
        
        // Main
        usersRoute.post("signup", use: signUp)
        usersRoute.get("searchusersnosql", ":searchterm", ":searchfield", use: searchUsersNoSQL)
        usersRoute.get("searchuserssql", ":term", use: searchUsersSQL)
        usersRoute.get("getavatar", ":avatarid", use: getAvatar)
        usersRoute.get(use: getAllHandler) // load all users
        
        let basicAuthMiddleware = UserRSM.authenticator()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        // Main
        basicAuthGroup.post("login", use: login)
        basicAuthGroup.post("signin", use: signIn)
        
        let tokenAuthMiddleware = TokenRSM.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Test
        
        
        // Main
        tokenAuthGroup.post("confirmgmail", use: confirmGmail)
        tokenAuthGroup.post("confirmotp", ":otp", use: confirmOTP)
        
        tokenAuthGroup.post(use: signUp)
        
        tokenAuthGroup.put("editprofile", use: editProfile)
        tokenAuthGroup.put("updateavatar", use: updateAvatar)
        
        tokenAuthGroup.delete("logout", use: logout)
        tokenAuthGroup.delete("clearsessionuser", use: logoutAllDevices)
        
    }
    
    // MARK: - Sign up.
    ///
    func signUp(_ req: Request) throws -> EventLoopFuture<UserRSM.Public> {
        let user = try req.content.decode(UserRSM.self)
        let userNoSQL = try req.content.decode(CreateUserRSMNoSQL.self)
        user.password = try Bcrypt.hash(user.password)
        return user.save(on: req.db).map {
            signUpNoSQL(userNoSQL, id: user.id!, on: req)
            return user.convertToPublic()
        }
    }
    
    func signUpNoSQL(_ user: CreateUserRSMNoSQL, id: UUID, on req: Request) {
        let personalData = PersonalData(
            phoneNumber: user.phoneNumber,
            email: user.email,
            dob: user.dob,
            idDevice: user.idDevice,
            block: [],
            gender: user.gender
        )
        let userNoSQL = UserRSMNoSQL(_id: ObjectId(),
                                     idOnRDBMS: id,
                                     
                                     name: user.name,
                                     username: user.username,
                                     
                                     lastName: user.lastName,
                                     bio: user.bio,
                                     
                                     privacy: user.privacy,
                                     defaultAvartar: user.defaultAvartar,
                                     personalData: personalData,
                                     
                                     followers: [],
                                     followings: [],
                                     boxes: []
        )
        CoreEngine.createUser(userNoSQL, inDatabase: req.mongoDB)
    }
    
    
    
    // MARK: - Log in.
    ///
    func signIn(_ req: Request) throws -> EventLoopFuture<TokenRSM> {
        let user = try req.auth.require(UserRSM.self)
        let token = try TokenRSM.generate(for: user)
        return token.save(on: req.db).map { token }
    }
    
    ///
    func login(_ req: Request) throws -> EventLoopFuture<TokenRSM> {
        let user = try req.auth.require(UserRSM.self)
        let token = try TokenRSM.generate(for: user)
        return token.save(on: req.db).map { token }
    }
    
    
    
    // MARK: - Search users.
    /// SQL
    func searchUsersSQL(_ req: Request) throws -> EventLoopFuture<[UserRSM]> {
        guard let searchTerm = req
                .query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return UserRSM.query(on: req.db).group(.or) { or in
            or.filter(\.$name == searchTerm)
            or.filter(\.$lastName == searchTerm)
            or.filter(\.$phoneNumber == searchTerm)
            or.filter(\.$email == searchTerm)
            or.filter(\.$dob == searchTerm)
        }.all()
    }
    /// NoSQL
    func searchUsersNoSQL(_ req: Request) throws -> EventLoopFuture<[UserRSMNoSQLPublic]> {
        guard let searchTerm = req.parameters.get("searchterm"),
              let searchField = req.parameters.get("searchfield"),
              let searchCase = SearchUserCases(rawValue: searchField) else {
            throw Abort(.badRequest)
        }
        return CoreEngine.findUsers(has: searchTerm, of: searchCase, inDatabase: req.mongoDB).convertToPublicData()
    }
    
    
    
    // MARK: - Edit profile.
    ///
    func editProfile(_ req: Request) throws -> EventLoopFuture<UserRSM.Public> {
        let updateData = try req.content.decode(UpdateUserRSM.self)
        let user = try req.auth.require(UserRSM.self)
//        let userID = try user.requireID()
        
//        return UserRSM
//            .find(req.parameters.get("userId"), on: req.db)
//            .unwrap(or: Abort(.notFound)).flatMap { user in
//                user.name = updateData.name
//                user.username = updateData.username
//                user.lastName = updateData.lastName
//                user.phoneNumber = updateData.phoneNumber
//                user.email = updateData.email
//                user.dob = updateData.dob
//                user.gender = updateData.gender
//                user.bio = updateData.bio
//                user.privacy = updateData.privacy
//                user.defaultAvartar = updateData.defaultAvartar
//                user.idDevice = updateData.idDevice
//                return user.save(on: req.db).map {
//                    user.convertToPublic()
//                }
//            }
        
        user.name = updateData.name
        user.username = updateData.username
        user.lastName = updateData.lastName
        user.phoneNumber = updateData.phoneNumber
        user.email = updateData.email
        user.dob = updateData.dob
        user.gender = updateData.gender
        user.bio = updateData.bio
        user.privacy = updateData.privacy
        user.defaultAvartar = updateData.defaultAvartar
        user.idDevice = updateData.idDevice
        
        return user.save(on: req.db).map {
            user.convertToPublic()
        }
    }
    
    ///
    func updateAvatar(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(UserRSM.self)
        let updateAvatar = try req.content.decode(Avatar.self)
        let fileId: EventLoopFuture<ObjectId?>
        
        if let file = updateAvatar.file, !file.isEmpty {
            // Upload the attached file to GridFS
            fileId = CoreEngine.uploadFile(file, inDatabase: req.mongoDB).map { fileId in
                // This is needed to map the EventLoopFuture from `ObjectId` to `ObjectId?`
                return fileId
            }
        } else {
            fileId = req.eventLoop.makeSucceededFuture(nil)
        }
        return fileId.flatMap { id in
            return CoreEngine.updateAvatar(of: user.id!, with: id!, inDatabase: req.mongoDB)
        }.transform(to: .ok)
    }
    
    
    
    // MARK: - Get data.
    func getAllHandler(_ req: Request) -> EventLoopFuture<[UserRSM]> {
        UserRSM.query(on: req.db).all()
    }
    func getAllToken(_ req: Request) -> EventLoopFuture<[TokenRSM]> {
        TokenRSM.query(on: req.db).all()
    }
    
    func getAllUserData(_ req: Request) -> EventLoopFuture<[UserRSMNoSQL]> {
        return CoreEngine.findAllUsers(inDatabase: req.mongoDB).map { users in
            return users
        }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<UserRSM.Public> {
        UserRSM.find(req.parameters.get("userId"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublicRSM()
    }
    
    ///
    func getAvatar(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let fileId = req.parameters.get("avatarid", as: ObjectId.self) else {
            throw Abort(.notFound)
        }
        
        return CoreEngine.readFile(byId: fileId, inDatabase: req.mongoDB).map { data in
            return Response(body: Response.Body(data: data))
        }
    }
    
    
    
    // MARK: - Log out.
    ///
    func logout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.auth.require(TokenRSM.self)
        try req.auth.logout(User.self)
//        return TokenRSM.find(req.parameters.get("tokenId"), on: req.db)
//          .unwrap(or: Abort(.notFound))
//          .flatMap { token in
//            token.delete(on: req.db)
//              .transform(to: .noContent)
//        }
        
        return token.delete(on: req.db).transform(to: .ok)
    }
    
    ///
    func logoutAllDevices(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.auth.require(TokenRSM.self)
        try req.auth.logout(User.self)
        let user = try req.auth.require(UserRSM.self)
        return TokenRSM
            .query(on: req.db)
            .group(.or) { or in
                or.filter(\.$user.$id == user.id!)
            }
            .delete()
            .transform(to: .ok)
        
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        UserRSM
            .find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym
                    .delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // Confirm Gmail.
    ///
    func confirmGmail(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(UserRSM.self)
        let otp = String(Int.random(in: 10000000...99999999))

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.timeZone = TimeZone.current
        let current = formatter.string(from: Date())
        let stringCurrent = formatter.date(from: current)
        let inMillis = stringCurrent!.timeIntervalSince1970
//        print(current)
//        print(stringCurrent)
        print(inMillis)

        user.otp = otp
        user.tsotp = "\(inMillis)"
        
        return try CoreEngine.sendEmail(req, recipient: user.email!, name: user.name, otp: otp).map {_ in
            user.save(on: req.db)
            return .ok
        }
    }
    
    func confirmOTP(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let otp = req.parameters.get("otp") else {
            throw Abort(.badRequest)
        }
        let user = try req.auth.require(UserRSM.self)
        if user.otp == otp {
            throw Abort(.ok)
        } else {
            throw Abort(.notAcceptable)
        }
    }
}


