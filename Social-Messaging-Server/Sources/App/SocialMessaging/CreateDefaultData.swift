//
//  CreateDefaultData.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Foundation
import MongoKitten

func createTestingUsersSM(inDatabase database: MongoDatabase) throws {
    let userCount = try database[UserSM.collection].count().wait()
    if userCount > 0 {
        // The testing users have already been created
        return
    }
    
    let ray = try UserSM(
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
