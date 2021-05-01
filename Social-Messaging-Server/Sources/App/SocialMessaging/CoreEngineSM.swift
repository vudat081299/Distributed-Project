//
//  CoreEngineSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor
import MongoKitten

struct CoreEngineSM {
    
    static func findUser(
        byUsername username: String,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserSM?> {
        return database[UserSM.collection].findOne(
            "credentials.username" == username,
            as: UserSM.self
        )
    }
    
    static func createUser(
        _ user: UserSM,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Void> {
        return database[UserSM.collection].insertEncoded(user).map { _ in }
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

    static func findAllUsers(
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserSM]> {
        let usersCollection = database[UserSM.collection]
        let result = try usersCollection.findAll(as: UserSM.self)
        return result
    }
    
    
}



extension MongoCollection {
//    public func findAll<D: Decodable>(_ query: Document = [:], as type: D.Type) -> EventLoopFuture<[D]> {
//        return find(query).decode(type).allResults()
//    }




}
