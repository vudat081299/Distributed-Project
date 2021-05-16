//
//  MessagesController.swift
//  
//
//  Created by Dat vu on 29/04/2021.
//

import Vapor
import Fluent
import MongoKitten

struct MessagesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "mess")
        
        let tokenAuthMiddleware = TokenRSM.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //
        
        // Main
        tokenAuthGroup.get("box", ":userId", use: loadAllBoxesOfUser)
        tokenAuthGroup.get("messageinrange", ":boxId", ":before", ":limit", use: loadAllMessagesInBoxInRange)
        tokenAuthGroup.get("messesinbox", ":boxId", use: loadAllMessagesInBox)
        
        tokenAuthGroup.post(use: mess)
        
        
        //
        acronymsRoutes.get("messesinbox", use: loadAllMessagesInBox)
        acronymsRoutes.get(":userId", use: loadAllBoxesOfUser)
        acronymsRoutes.get("all", use: loadAllBoxes)
        
        
    }
    
    /// Check of box is existed, if not create box.
    func mess(_ req: Request) throws -> EventLoopFuture<Box> {
        let user = try req.auth.require(UserRSM.self)
        let data = try req.content.decode(CreateBox.self)
        return CoreEngine.checkBoxIfExisted(data: data, of: user, inDatabase: req.mongoDB)
    }
    
    func loadAllBoxes(_ req: Request) throws -> EventLoopFuture<[Box]> {
        return CoreEngine.loadAllBoxes(inDatabase: req.mongoDB)
    }
    
    func loadAllBoxesOfUser(_ req: Request) throws -> EventLoopFuture<[Box]> {
        guard let _id = req.parameters.get("userId", as: ObjectId.self) else {
            throw Abort(.badRequest)
        }
//        return CoreEngine.findUser(has: user.id!.uuidString, of: "idOnRDBMS", inDatabase: req.mongoDB).flatMap { user in
//            print(user._id)
        return CoreEngine.loadAllBoxesOfUser(of: _id, inDatabase: req.mongoDB)
//        }
    }
    
    func loadAllMessagesInBox(_ req: Request) throws -> EventLoopFuture<[Message]> {
        guard let boxId = req.parameters.get("boxId", as: ObjectId.self) else {
            throw Abort(.badRequest)
        }
        return CoreEngine.loadAllMessagesInBox(of: boxId, inDatabase: req.mongoDB)
    }
    
    func loadAllMessagesInBoxInRange(_ req: Request) throws -> EventLoopFuture<[Message]> {
        guard let boxId = req.parameters.get("boxId", as: ObjectId.self),
              let before = req.parameters.get("before", as: Int.self),
              let limit = req.parameters.get("limit", as: Int.self)
        else {
            throw Abort(.badRequest)
        }
        // convert Int to TimeInterval (typealias for Double)
        let timeInterval = TimeInterval(before)

        // create NSDate from Double (NSTimeInterval)
        let myNSDate = Date(timeIntervalSince1970: timeInterval)
        
        print(myNSDate)
        return CoreEngine.loadMessagesInBoxInRange(
            of: boxId,
            before: myNSDate,
            limit: limit,
            inDatabase: req.mongoDB
        )
    }

}
