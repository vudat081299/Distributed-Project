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
        let acronymsRoutes = routes.grouped("api", "messaging")
        // Main
        acronymsRoutes.get("getfile", ":fileObjectId", use: getFile)
        
        let tokenAuthMiddleware = TokenRSM.authenticator()
        let guardAuthMiddleware = UserRSM.guardMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        //
        
        // Main
        tokenAuthGroup.get("boxes", "data", ":userObjectId", use: loadAllBoxesOfUser)
        tokenAuthGroup.get("messageinrange", ":boxId", ":before", ":limit", use: loadAllMessagesInBoxInRange)
        tokenAuthGroup.get("data", ":boxObjectId", use: loadAllMessagesInBox)
        
        tokenAuthGroup.post(use: mess)
        tokenAuthGroup.post("send", "mess", use: sendMess)
        tokenAuthGroup.post("postfile", use: postFile)
        
        
        //
        acronymsRoutes.get("messesinbox", use: loadAllMessagesInBox)
        acronymsRoutes.get(":userId", use: loadAllBoxesOfUser)
        acronymsRoutes.get("all", use: loadAllBoxes)
        
        
    }
    
    
    ///
    func getFile(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let fileObjectId = req.parameters.get("fileObjectId", as: ObjectId.self) else {
            throw Abort(.notFound)
        }
        
        return CoreEngine.readFile(byId: fileObjectId, inDatabase: req.mongoDB).map { data in
            return Response(body: Response.Body(data: data))
        }
    }
    
    
    /// Check of box is existed, if not create box.
    func mess(_ req: Request) throws -> EventLoopFuture<Box> {
        let user = try req.auth.require(UserRSM.self)
        let data = try req.content.decode(CreateBox.self)
        return CoreEngine.checkBoxIfExisted(data: data, of: user, inDatabase: req.mongoDB)
    }
    
    func postFile(_ req: Request) throws -> EventLoopFuture<FileUpload> {
        let data = try req.content.decode(FileUpload.self)
        let fileObjectId: EventLoopFuture<ObjectId?>

        if let file = data.file, !file.isEmpty {
            // Upload the attached file to GridFS
            fileObjectId = CoreEngine.uploadFile(file, inDatabase: req.mongoDB).map { fileObjectId in
                // This is needed to map the EventLoopFuture from `ObjectId` to `ObjectId?`
                return fileObjectId
            }
        } else {
            fileObjectId = req.eventLoop.makeSucceededFuture(nil)
        }
        return fileObjectId.flatMapThrowing { id in
            guard let id = id else {
                throw Abort(.badRequest)
            }
            return FileUpload(fileObjectId: id.hexString)
        }
    }
    
    func sendMess(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let data = try req.content.decode(WSResolvedData.self)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return messingHandler(data: data.majorData, of: req, using: decoder).transform(to: .ok)
    }
    
    func loadAllBoxes(_ req: Request) throws -> EventLoopFuture<[Box]> {
        return CoreEngine.findAllBoxes(inDatabase: req.mongoDB)
    }
    
    func loadAllBoxesOfUser(_ req: Request) throws -> EventLoopFuture<[Box]> {
        guard let userObjectId = req.parameters.get("userObjectId", as: ObjectId.self) else {
            throw Abort(.badRequest)
        }
//        return CoreEngine.findUser(has: user.id!.uuidString, of: "idOnRDBMS", inDatabase: req.mongoDB).flatMap { user in
//            print(user._id)
        return CoreEngine.findAllBoxes(of: userObjectId, inDatabase: req.mongoDB)
//        }
    }
    
    func loadAllMessagesInBox(_ req: Request) throws -> EventLoopFuture<[Message]> {
        guard let boxObjectId = req.parameters.get("boxObjectId", as: ObjectId.self) else {
            throw Abort(.badRequest)
        }
        return CoreEngine.loadAllMessages(of: boxObjectId, inDatabase: req.mongoDB)
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
        return CoreEngine.loadMessages(
            of: boxId,
            before: myNSDate,
            limit: limit,
            inDatabase: req.mongoDB
        )
    }

}
