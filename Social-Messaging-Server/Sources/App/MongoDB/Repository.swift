//    Copyright (c) 2020 Razeware LLC
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without
//    restriction, including without limitation the rights to use,
//    copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom
//    the Software is furnished to do so, subject to the following
//    conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    Notwithstanding the foregoing, you may not use, copy, modify,
//    merge, publish, distribute, sublicense, create a derivative work,
//    and/or sell copies of the Software in any work that is designed,
//    intended, or marketed for pedagogical or instructional purposes
//    related to programming, coding, application development, or
//    information technology. Permission for such use, copying,
//    modification, merger, publication, distribution, sublicensing,
//    creation of derivative works, or sale is expressly withheld.
//
//    This project and source code may use libraries or frameworks
//    that are released under various Open-Source licenses. Use of
//    those libraries and frameworks are governed by their own
//    individual licenses.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//    DEALINGS IN THE SOFTWARE.

import Vapor
import MongoKitten

struct Repository {
    static func getFeed(
        forUser userId: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[ResolvedTimelinePost]> {
        return findUser(byId: userId, inDatabase: database).flatMap { user in
            // Users you're following and yourself
            var feedUserIds = user.following
            feedUserIds.append(userId)
              
            let followingUsersQuery: Document = [
              "creator": [
                "$in": feedUserIds
              ]
            ]
            
            return database[TimelinePost.collection].buildAggregate {
                match(followingUsersQuery)
                sort([
                    "creationDate": .descending
                ])
                limit(10)
                lookup(
                    from: UserMongoDB.collection,
                    localField: "creator",
                    foreignField: "_id",
                    as: "creator"
                )
                unwind(fieldPath: "$creator")
            }.decode(ResolvedTimelinePost.self).allResults()
        }
    }
    
    static func findUser(
        byUsername username: String,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserMongoDB?> {
        return database[UserMongoDB.collection].findOne(
            "credentials.username" == username,
            as: UserMongoDB.self
        )
    }
    
    static func findSuggestedUsers(
        forUser userId: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<[UserMongoDB]> {
        let users = database[UserMongoDB.collection]
        return findUser(byId: userId, inDatabase: database).flatMap { user in
            // Users you're following and yourself
            var feedUserIds = user.following
            feedUserIds.append(userId)
            
            let otherUsersQuery: Document = [
                "_id": [
                    "$nin": feedUserIds
                ]
            ]
            
            return users.buildAggregate {
                match(otherUsersQuery)
                sample(5)
                sort([
                    "profile.firstName": .ascending,
                    "profile.lastName": .ascending
                ])
            }.decode(UserMongoDB.self).allResults()
        }
    }
    
    static func findUser(
        byId userId: ObjectId,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserMongoDB> {
        return database[UserMongoDB.collection].findOne("_id" == userId, as: UserMongoDB.self).flatMapThrowing { user in
            guard let user = user else {
                throw Abort(.notFound)
            }
            
            return user
        }
    }
    
    static func followUser(
        _ account: UserMongoDB,
        fromAccount follower: UserMongoDB,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Void> {
        return database[UserMongoDB.collection].updateOne(
            where: "_id" == follower._id,
            to: [
                "$push": [
                    "following": account._id
                ]
            ]
        ).map { _ in }
    }
    
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
    
    static func createPost(
        _ post: TimelinePost,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<Void> {
        return database[TimelinePost.collection].insertEncoded(post).map { _ in }
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
}
