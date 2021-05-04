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
        usersRoute.get(use: getAllHandler)
        usersRoute.get("nosql", use: getAllUserData)
        usersRoute.get(":userID", use: getHandler)
        
        // Main
        usersRoute.post("signup", use: signUp)
        
        let basicAuthMiddleware = UserRSM.authenticator()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        
        let tokenAuthMiddleware = TokenRSM.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        usersRoute.get("token", use: getAllToken)
        tokenAuthGroup.post(use: signUp)
        tokenAuthGroup.delete(":userId", use: logout)
        tokenAuthGroup.delete("clearsessionuser", use: logoutAllDevices)
        tokenAuthGroup.put(":userId", use: updateHandler)
    }
    
    // MARK: - Sign up.
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
            block: [])
        let userNoSQL = UserRSMNoSQL(
            _id: ObjectId(),
            idOnRDBMS: id,
            name: user.name,
            username: user.username,
            lastName: user.lastName,
            gender: user.gender,
            bio: user.bio,
            privacy: user.privacy!,
            defaultAvartar: user.defaultAvartar,
            profilePicture: user.profilePicture,
            personalData: personalData,
            following: [],
            box: [])
        
        CoreEngine.createUser(userNoSQL, inDatabase: req.mongoDB)
    }
    
    
    
    // MARK: - Log in.
    func signIn(_ req: Request) throws -> EventLoopFuture<TokenRSM> {
        let user = try req.auth.require(UserRSM.self)
        let token = try TokenRSM.generate(for: user)
        return token.save(on: req.db).map { token }
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<TokenRSM> {
        let user = try req.auth.require(UserRSM.self)
        let token = try TokenRSM.generate(for: user)
        return token.save(on: req.db).map { token }
    }
    
    func editProfile(_ req: Request) throws -> EventLoopFuture<TokenRSM> {
        let user = try req.auth.require(UserRSM.self)
        let token = try TokenRSM.generate(for: user)
        return token.save(on: req.db).map { token }
    }
    
    
    
    // MARK: - Edit profile.
    func updateHandler(_ req: Request) throws -> EventLoopFuture<UserRSM.Public> {
        let updateData = try req.content.decode(UpdateUserRSM.self)
//        let user = try req.auth.require(User.self)
//        let userID = try user.requireID()
        return UserRSM.find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
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
    }
    
    
    
    // MARK: - Get data.
    func getAllHandler(_ req: Request) -> EventLoopFuture<[UserRSM.Public]> {
        UserRSM.query(on: req.db).all().convertToPublicRSM()
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
        UserRSM.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublicRSM()
    }
    
    
    
    // MARK: - Log out.
    func logout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let token = try req.auth.require(TokenRSM.self)
        return TokenRSM.find(req.parameters.get("tokenId"), on: req.db)
          .unwrap(or: Abort(.notFound))
          .flatMap { token in
            token.delete(on: req.db)
              .transform(to: .noContent)
        }
    }
    
    func logoutAllDevices(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        guard let userId = req.query[String.self, at: "userid"] else {
//            throw Abort(.badRequest)
//        }
        let token = try req.auth.require(TokenRSM.self)
        let user = try req.auth.require(UserRSM.self)
        
//        TokenRSM.query(on: req.db).filter(\.$type == .gasGiant)
//        TokenRSM.query(on: req.db).filter(\.$user == token)
        return TokenRSM.query(on: req.db).group(.or) { or in
            or.filter(\.$user.$id == user.id!)
        }.delete()
        .transform(to: .ok)
        
    }
}
