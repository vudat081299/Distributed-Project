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
    
    // MARK: - User.
    static func createUser(_ user: UserRSMNoSQL, inDatabase database: MongoDatabase) -> EventLoopFuture<Void> {
        return database[UserRSMNoSQL.collection].insertEncoded(user).map { _ in }
    }
    
    static func findUser(
        of id: UUID,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserRSMNoSQL]> {
        return database[UserRSMNoSQL.collection]
            .findUsers(
                [
                    "idOnRDBMS": [
                        "$regex": id.uuidString
                    ]
                 
                ],
            as: UserRSMNoSQL.self
        )
    }
    
    static func findUsers(
        has searchTerm: String,
        of field: SearchUserCases,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserRSMNoSQL]> {
        return database[UserRSMNoSQL.collection]
            .findUsers(
                [
                    field.rawValue: [
                        "$regex": searchTerm
                    ]
                 
                ],
            as: UserRSMNoSQL.self
        )
    }
    
    static func findAllUsers(
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
    
    // MARK: - File interact.
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
    
    
    
    // MARK: - Mail sender.
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
    public func findUsers<D: Decodable>(_ query: Document = [:], as type: D.Type) -> EventLoopFuture<[D]> {
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
