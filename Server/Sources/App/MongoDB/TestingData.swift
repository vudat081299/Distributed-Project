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

import Foundation
import MongoKitten

func createTestingUsers(inDatabase database: MongoDatabase) throws {
    let userCount = try database[UserMongoDB.collection].count().wait()
    if userCount > 0 {
        // The testing users have already been created
        return
    }
    
    let ray = try UserMongoDB(
        _id: ObjectId(),
        profile: UserProfile(
            firstName: "Ray",
            lastName: "Wenderlich"
        ),
        credentials: EncryptedCredentials(
            username: "ray",
            password: "beachvacations"
        ),
        following: []
    )
    
    let tim = try UserMongoDB(
        _id: ObjectId(),
        profile: UserProfile(
            firstName: "Tim",
            lastName: "Cordon"
        ),
        credentials: EncryptedCredentials(
            username: "0xtim",
            password: "0xpassword"
        ),
        following: []
    )
    
    let joannis = try UserMongoDB(
        _id: ObjectId(),
        profile: UserProfile(
            firstName: "Joannis",
            lastName: "Orlandos"
        ),
        credentials: EncryptedCredentials(
            username: "Joannis",
            password: "hunter2"
        ),
        following: []
    )
    
    let names = [
        ("Chris", "Lattner"),
        ("Tim", "Cook"),
    ]
    
    let otherUsers = try names.map { (firstName, lastName) in
        try UserMongoDB(
            _id: ObjectId(),
            profile: UserProfile(
                firstName: firstName,
                lastName: lastName
            ),
            credentials: EncryptedCredentials(
                username: "\(firstName).\(lastName)",
                password: "1234"
            ),
            following: []
        )
    }
    
    var posts = [TimelinePost]()
    
    posts.append(
        TimelinePost(
            _id: ObjectId(),
            text: "Breaking news: Vapor formed into clouds",
            creationDate: Date(),
            fileId: nil,
            creator: joannis._id
        )
    )
    
    posts.append(
        TimelinePost(
            _id: ObjectId(),
            text: "MongoKitten needs a sequel!",
            creationDate: Date(),
            fileId: nil,
            creator: joannis._id
        )
    )
    
    let tutorialNames = [
        "Baking HTTP Cookies",
        "Knitting TCP Socks"
    ]
    
    let tutorialPosts = tutorialNames.map { tutorial in
        TimelinePost(
            _id: ObjectId(),
            text: "A new tutorial on \(tutorial)!",
            creationDate: Date(),
            fileId: nil,
            creator: ray._id
        )
    }
    
    posts.append(contentsOf: tutorialPosts)
    let mainUser = try UserMongoDB(
        _id: ObjectId(),
        profile: UserProfile(firstName: "Me", lastName: ""),
        credentials: EncryptedCredentials(
            username: "me",
            password: "opensesame"
        ),
        // One user is being followed to start off, so that the timeline isn't empty
        following: [ray._id]
    )
    
    let createdAdmin = database[UserMongoDB.collection].insertEncoded(mainUser)
    let createdUsers = database[UserMongoDB.collection].insertManyEncoded([
        ray,
        tim,
        joannis
    ] + otherUsers)
    let createdPosts = database[TimelinePost.collection].insertManyEncoded(posts)
    
    _ = try createdAdmin.and(createdUsers).and(createdPosts).wait()
}
