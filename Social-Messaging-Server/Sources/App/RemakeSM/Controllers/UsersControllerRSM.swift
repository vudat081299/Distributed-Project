//
//  UsersControllerRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor

struct UsersControllerRSM: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        
        // Main
        usersRoute.post("signup", use: signUp)
        usersRoute.post("login", use: login)
        
        let basicAuthMiddleware = UserRSM.authenticator()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: signUp)
    }
    
    func signUp(_ req: Request) throws -> EventLoopFuture<UserRSM.Public> {
        let user = try req.content.decode(UserRSM.self)
        user.password = try Bcrypt.hash(user.password)
        return user.save(on: req.db).map { user.convertToPublic() }
    }
    
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
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[UserRSM.Public]> {
        UserRSM.query(on: req.db).all().convertToPublicRSM()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<UserRSM.Public> {
        UserRSM.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublicRSM()
    }
}
