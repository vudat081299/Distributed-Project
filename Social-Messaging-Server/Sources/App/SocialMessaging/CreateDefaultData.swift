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
        profile: UserProfileSM(
            firstName: "Tim", lastName: "Tim", phoneNumber: "Tim", email: "Tim",
            dateOfBirth: "Ray",
            bio: "Wenderlich"
        ),
        credentials: EncryptedCredentialsSM(
            username: "ray",
            password: "beachvacations"
        ),
        following: [],
        followers: []
    )
    
    let tim = try UserSM(
        _id: ObjectId(),
        profile: UserProfileSM(
            firstName: "Tim", lastName: "Tim", phoneNumber: "Tim", email: "Tim",
            dateOfBirth: "Tim",
            bio: "Cordon"
        ),
        credentials: EncryptedCredentialsSM(
            username: "0xtim",
            password: "0xpassword"
        ),
        following: [],
        followers: []
    )
    
    let joannis = try UserSM(
        _id: ObjectId(),
        profile: UserProfileSM(
            firstName: "Joannis", lastName: "Joannis", phoneNumber: "Joannis", email: "Joannis",
            dateOfBirth: "Joannis",
            bio: "Orlandos"
        ),
        credentials: EncryptedCredentialsSM(
            username: "Joannis",
            password: "hunter2"
        ),
        following: [],
        followers: []
    )
    
    let names = [
        ("Chris", "Lattner"),
        ("Tim", "Cook"),
    ]
    
    let otherUsers = try names.map { (firstName, lastName) in
        try UserSM(
            _id: ObjectId(),
            profile: UserProfileSM(
                firstName: "Tim", lastName: "Tim", phoneNumber: "Tim", email: "Tim",
                dateOfBirth: firstName,
                bio: lastName
            ),
            credentials: EncryptedCredentialsSM(
                username: "\(firstName).\(lastName)",
                password: "1234"
            ),
            following: [],
            followers: []
        )
    }
    
    var posts = [Message]()
    
    posts.append(
        Message(
            _id: ObjectId(),
            text: "Breaking news: Vapor formed into clouds",
            creationDate: Date(),
            fileId: nil,
            creator: joannis._id
        )
    )
    
    posts.append(
        Message(
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
        Message(
            _id: ObjectId(),
            text: "A new tutorial on \(tutorial)!",
            creationDate: Date(),
            fileId: nil,
            creator: ray._id
        )
    }
    
    posts.append(contentsOf: tutorialPosts)
    let mainUser = try UserSM(
        _id: ObjectId(),
        profile: UserProfileSM(firstName: "Me", lastName: "Tim", phoneNumber: "Tim", email: "Tim",
                               dateOfBirth: "Tim",
                               bio: "Tim"),
        credentials: EncryptedCredentialsSM(
            username: "me",
            password: "opensesame"
        ),
        // One user is being followed to start off, so that the timeline isn't empty
        following: [ray._id],
        followers: []
    )
    
    let createdAdmin = database[UserSM.collection].insertEncoded(mainUser)
    let createdUsers = database[UserSM.collection].insertManyEncoded([
        ray,
        tim,
        joannis
    ] + otherUsers)
    let createdPosts = database[Message.collection].insertManyEncoded(posts)
    
    _ = try createdAdmin.and(createdUsers).and(createdPosts).wait()
}
