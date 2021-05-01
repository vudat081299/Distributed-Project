//
//  UsersControllerRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor
import MongoKitten

struct UsersControllerRSM: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get("nosql", use: getAllUserData)
        usersRoute.get(":userID", use: getHandler)
        
        // Main
        usersRoute.post("signup", use: signUp)
        usersRoute.post("login", use: login)
        
        let basicAuthMiddleware = UserRSM.authenticator()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        
        let tokenAuthMiddleware = TokenRSM.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: signUp)
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
            bio: user.bio,
            privacy: user.privacy!,
            profilePicture: user.profilePicture,
            personalData: personalData,
            following: [],
            box: [])
        
        CoreEngine.createUser(userNoSQL, inDatabase: req.mongoDB)
    }
    
    
    
    // MARK: - Sign in.
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
    
    
    
    
    // MARK: - Get data.
    func getAllHandler(_ req: Request) -> EventLoopFuture<[UserRSM.Public]> {
        UserRSM.query(on: req.db).all().convertToPublicRSM()
    }
    
    func getAllUserData(_ req: Request) -> EventLoopFuture<[UserRSMNoSQL]> {
        return CoreEngine.findAllUsers(inDatabase: req.mongoDB).map { users in
            return users
        }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<UserRSM.Public> {
        UserRSM.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublicRSM()
    }
}
