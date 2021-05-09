//
//  Box.swift
//  
//
//  Created by Dat vu on 29/04/2021.
//

import Vapor
import MongoKitten

struct BoxSpecification: Codable, Content {
    let name: String?
    let avartar: ObjectId?
    let creator: UUID
    let creator_id: ObjectId?
    let createdAt: Date
}

struct Box: Codable, Content {
    static let collection = "boxes"

    let _id: ObjectId
    let type: BoxType
    let boxSpecification: BoxSpecification
    var members: [UUID]
    var members_id: [ObjectId]
//    var messages: [Messages]
}

struct CreateBox: Codable {
    let type: BoxType
    var members: [UUID]
    var members_id: [ObjectId]
    
    let creator_id: ObjectId?
    let createdAt: Date
}

enum MediaType: Int, Content {
    case png, text, jpg, mp4
}

enum BoxType: Int, Content {
    case privateChat, group
}
