//
//  Non-classify.swift
//  Social Messaging
//
//  Created by Dat vu on 12/05/2021.
//

import Foundation


/// Use to create chat box.
struct Box: Codable {
    let generatedString: String
    let type: BoxType
    var members: [UUID?]
    var members_id: [String?]
    let membersName: [String?]
    
    let creator_id: String?
    let createdAt: String
}

enum BoxType: Int, Codable {
    case privateChat, group
}

struct ResolvedBox: Codable {
    let _id: String
    let generatedString: String?
    let type: BoxType
    let boxSpecification: BoxSpecification
    var members: [UUID]
    var members_id: [String]
    let membersName: [String]
}

struct BoxSpecification: Codable {
    let name: String?
    let avartar: String?
    let creator: UUID
    let creator_id: String?
    let creatorName: String?
    let createdAt: Date
    let lastestMess: String?
    let lastestUpdate: Date
}
{
    "lastName": "vudat81299",
    "personalData": {
        "email": "vudat81299@gmail.com",
        "dob": "24/08/2000",
        "block": [],
        "gender": 0,
        "phoneNumber": "0899081299"
    },
    "_id": "609ea00683818e382c32bbd8",
    "followings": [],
    "bio": "🐝 I’m student at Ha Noi University of Science and Technology. 🐝 I’m student at Ha Noi University of Science and Technology. 🐝 I’m student at Ha Noi University of Science and Technology. 🐝 I’m student at Ha Noi University of Science and Technology. 🐝 I’m student at Ha Noi University of Science and Technology.",
    "defaultAvartar": 0,
    "username": "vudat81299",
    "boxes": [
        "60a0c09a1d5f86a3bee4581c",
        "60a0c1aec43d91d8959e078e",
        "60a0c4a6d41b94d16d43b6d7"
    ],
    "privacy": 0,
    "followers": [],
    "name": "vudat81299",
    "idOnRDBMS": "FECE0C19-60BE-4DFC-87BA-31749B9459F7"
},
