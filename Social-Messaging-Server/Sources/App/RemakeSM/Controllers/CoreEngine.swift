//
//  CoreEngine.swift
//  
//
//  Created by Vũ Quý Đạt  on 30/04/2021.
//

import Vapor
import MongoKitten
import VaporSMTPKit
import SMTPKitten

struct CoreEngine {
    
    
    
    // MARK: - Box
    static func createBox(_ box: Box, generatedString: String?, inDatabase database: MongoDatabase) -> EventLoopFuture<HTTPStatus> {
        "a" > "b"
        if generatedString != nil {
            checkPrivateBox(generatedString: generatedString!, inDatabase: database)
        }
        return database[Box.collection].insertEncoded(box).map { _ in }.transform(to: .ok)
    }
    
    static func loadAllBoxes(
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[Box]> {
        let usersCollection = database[Box.collection]
        let result = usersCollection.findAll(as: Box.self)
        return result
    }
    
    /// Load all boxes of User.
    static func loadAllBoxesOfUser(
        of userId: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[Box]> {
        return findUser(has: String(userId), of: "_id", inDatabase: database).flatMap { user in
            let boxes = user.boxes
            let boxesOfUserQuey: Document = [
              "_id": [
                "$in": boxes
              ]
            ]
            return database[Box.collection].buildAggregate {
                match(boxesOfUserQuey)
                sort([
                    "boxSpecification.createdAt": .descending
                ])
                project("messages")
            }.decode(Box.self).allResults()
        }
    }
    
    static func findBox(
        id: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Box> {
        return database[Box.collection]
            .findOne(
                "_id" == id,
                as: Box.self
            ).flatMapThrowing { box in
                guard let box = box else {
                    throw Abort(.notFound)
                }
                return box
            }
    }
    
    static func checkPrivateBox(
        generatedString: String,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Box> {
        return database[Box.collection]
            .findOne(
                "generatedString" == generatedString,
                as: Box.self
            ).flatMapThrowing { box in
                guard let box = box else {
                    throw Abort(.notFound)
                }
                if box != nil {
                    throw Abort(.notFound)
                }
                return box
            }
    }
    
//    static func updateBoxInfo(
//        of box: Box,
//        inDatabase database: MongoDatabase
//    ) -> EventLoopFuture<Void> {
//        database[Box.collection]
//            .updateOne(
//                where: "_id" == box._id,
//                to: [
//                    "$set": [
//                        "type": box.type
////                        "boxSpecification.name": box.boxSpecification.name,
////                        "boxSpecification.avatar": box.boxSpecification.avartar
//                    ]
//                ]
//            ).map { _ in }
//    }
    
//    static func followUser(
//        _ account: UserMongoDB,
//        fromAccount follower: UserMongoDB,
//        inDatabase database: MongoDatabase
//    ) -> EventLoopFuture<Void> {
//        return database[UserMongoDB.collection].updateOne(
//            where: "_id" == follower._id,
//            to: [
//                "$push": [
//                    "following": account._id
//                ]
//            ]
//        ).map { _ in }
//    }
    
    
    // MARK: - Mess handler.
    // load all messages of box.
    static func loadAllMessagesInBox(
        of boxId: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[Message]> {
        // method 1.
//        return database[Message.collection]
//            .findAll(
//                "boxId" == boxId,
//                as: Message.self
//            )
        
        // method 2.
        let queryMessages: Document = [
            "boxId": [
                "$eq": boxId
            ]
        ]
        return database[Message.collection].aggregate([
            .match(queryMessages),
            sort([
                "creationDate": .descending
            ])
        ]).decode(Message.self).allResults()
        
        // all messages in all boxes
//        let usersCollection = database[Message.collection]
//        let result = usersCollection.findAll(as: Message.self)
//        return result
    }
    
    static func loadMessagesInBoxInRange(
        of boxId: ObjectId,
        before: Date,
        limit: Int = 60,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[Message]> {
        let queryMessages: Document = [
            "creationDate": [
                "$lt": before
            ],
            "boxId": [
                "$eq": boxId
            ]
        ]
        return database[Message.collection].aggregate([
            .match(queryMessages),
            sort([
                "creationDate": .descending
            ]),
            .limit(limit)
        ]).decode(Message.self).allResults()
    }
    
    
    // create a mess in [].
    //    static func mess(box id: ObjectId, mess content: Message, inDatabase database: MongoDatabase) -> EventLoopFuture<Void> {
    //        return database[Box.collection].updateOne(
    //            where: "_id" == id,
    //            to: [
    //                "$push": [
    //                    "messages": content
    //                ]
    //            ]
    //        ).map { _ in }
    //    }
    static func mess(_ content: Message, inDatabase database: MongoDatabase) {
        database[Message.collection].insertEncoded(content).map { _ in }
    }
    
    /// Send file in mess.
    static func uploadMediaOfMess(
        _ file: Data,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<ObjectId> {
        let id = ObjectId() // 1
        let gridFS = GridFSBucket(in: database) // 2
        return gridFS.upload(file, id: id).map { // 3
          return id // 4
        }
    }
    
    static func readMediaOfMess(
        byId id: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Data> {
        let gridFS = GridFSBucket(in: database)
        
        return gridFS.findFile(byId: id).flatMap { file in
            guard let file = file else {
                return database.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            
            return file.reader.readData()
        }
    }
    
    
    
    // MARK: - User handler.
    static func createUser(_ user: UserRSMNoSQL, inDatabase database: MongoDatabase) -> EventLoopFuture<Void> {
        return database[UserRSMNoSQL.collection].insertEncoded(user).map { _ in }
    }
    
    static func findUser(
        has searchTerm: String,
        of field: String = "idOnRDBMS",
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserRSMNoSQL> {
        return database[UserRSMNoSQL.collection]
            .findOne(
                field == searchTerm,
                as: UserRSMNoSQL.self
            ).flatMapThrowing { user in
                guard let user = user else {
                    throw Abort(.notFound)
                }
                return user
            }
    }
        
    static func findUsers(
        has searchTerm: String,
        of field: SearchUserCases,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserRSMNoSQL]> {
        return database[UserRSMNoSQL.collection]
            .findAll(
                [
                    field.rawValue: [
                        "$regex": searchTerm
                    ]
                 
                ],
            as: UserRSMNoSQL.self
        )
    }
    
    static func updateUserProfile(
        of user: UserRSMNoSQL,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Void> {
        database[UserRSMNoSQL.collection]
            .updateOne(
                where: "idOnRDBMS" == user.idOnRDBMS.uuidString,
                to: [
                    "$set": [
                        "name": user.name,
                        "username": user.username,
                        "lastName": user.lastName,
                        "phoneNumber": user.personalData?.phoneNumber,
                        "email": user.personalData?.email,
                        "dob": user.personalData?.dob,
                        "gender": "\(String(describing: user.personalData?.gender))",
                        "bio": user.bio,
                        "privacy": "\(String(describing: user.privacy))",
                        "defaultAvartar": "\(String(describing: user.defaultAvartar))",
                        "idDevice": user.personalData?.idDevice
                    ]
                ]
            ).map { _ in }
    }
    
    static func loadAllUsers(
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserRSMNoSQL]> {
        let usersCollection = database[UserRSMNoSQL.collection]
        let result = usersCollection.findAll(as: UserRSMNoSQL.self)
        return result
    }
    
    static func updateAvatar(
        of userId: UUID,
        with file: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Void> {
        database[UserRSMNoSQL.collection]
            .updateOne(
            where: "idOnRDBMS" == userId.uuidString,
            to: [
                "$set": [
                    "profilePicture": file
                ]
            ]
        ).map { _ in }
    }
    
    
    
    // MARK: - File handler.
    static func uploadFile(
        _ file: Data,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<ObjectId> {
        let id = ObjectId() // 1
        let gridFS = GridFSBucket(in: database) // 2
        return gridFS.upload(file, id: id).map { // 3
          return id // 4
        }
    }
    
    static func readFile(
        byId id: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Data> {
        let gridFS = GridFSBucket(in: database)
        
        return gridFS.findFile(byId: id).flatMap { file in
            guard let file = file else {
                return database.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            
            return file.reader.readData()
        }
    }
    
    
    
    // MARK: - Mail Handler.
    static func sendEmail(
        _ req: Request,
        recipient: String,
        name: String, otp: String
    ) throws -> EventLoopFuture<String> {
        let email = Mail(
            from: "vudat081299@gmail.com",
            to: [
                MailUser(name: name, email: recipient)
            ],
            subject: "SM confirm",
            contentType: .html,
            text: """
                <h1>Mã bảo mật dùng 1 lần cho tài khoản SM của bạn</h1>
                Xin chào \(name),
                Mã bảo mật của bạn là: <strong>\(otp)</strong>

            """
        )
        
        return req.application.sendMail(email, withCredentials: .default).map {
            return "Check your mail!"
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Deprecated

//    static func loadAllUsers(
//        forUser userId: ObjectId,
//        inDatabase database: MongoDatabase
//    ) -> EventLoopFuture<[UserSM]> {
//        let users = database[UserSM.collection]
//        return findUser(byId: userId, inDatabase: database).flatMap { user in
//            // Users you're following and yourself
//            var feedUserIds = user.following
//            feedUserIds.append(userId)
//
//            let otherUsersQuery: Document = [
//                "_id": [
//                    "$nin": feedUserIds
//                ]
//            ]
//
//            return users.buildAggregate {
//                match(otherUsersQuery)
//                sample(5)
//                sort([
//                    "profile.firstName": .ascending,
//                    "profile.lastName": .ascending
//                ])
//            }.decode(UserSM.self).allResults()
//        }
//    }
    
//    static func findUser(
//        inDatabase database: MongoDatabase
//    ) -> EventLoopFuture<UserSM> {
//        return database[UserSM.collection].find("_id" != nil, as: UserSM.self).flatMapThrowing { user in
//            guard let user = user else {
//                throw Abort(.notFound)
//            }
//            return user
//        }
//    }
    
    
}



extension MongoCollection {
    public func findAll<D: Decodable>(_ query: Document = [:], as type: D.Type) -> EventLoopFuture<[D]> {
        return find(query).decode(type).allResults()
    }
}


// MARK: - Support mail sender.
extension SMTPCredentials {
    static var `default`: SMTPCredentials {
        return SMTPCredentials(
            hostname: "smtp.gmail.com",
            ssl: .startTLS(configuration: .default),
            email: "vudat081299@gmail.com",
            password: "Iviundhacthi8987g"
        )
    }
}
