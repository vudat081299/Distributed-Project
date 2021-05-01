//
//  CoreEngine.swift
//  
//
//  Created by Vũ Quý Đạt  on 30/04/2021.
//

import Vapor
import MongoKitten

struct CoreEngine {
    
    
    
    static func createUser(_ user: UserRSMNoSQL, inDatabase database: MongoDatabase) -> EventLoopFuture<Void> {
        return database[UserRSMNoSQL.collection].insertEncoded(user).map { _ in }
    }
    
    static func findAllUsers(
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserRSMNoSQL]> {
        let usersCollection = database[UserRSMNoSQL.collection]
        let result = try usersCollection.findAll(as: UserRSMNoSQL.self)
        return result
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Deprecated
    
    static func findUser(
        byUsername username: String,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserRSMNoSQL?> {
        return database[UserRSMNoSQL.collection].findOne(
            "credentials.username" == username,
            as: UserRSMNoSQL.self
        )
    }

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

