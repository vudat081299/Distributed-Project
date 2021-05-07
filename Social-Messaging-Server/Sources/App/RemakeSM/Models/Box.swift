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
    let creator: ObjectId
    let createdAt: Date
}

struct Box: Codable, Content {
    static let collection = "boxes"

    let _id: ObjectId
    let type: BoxType
    let boxSpecification: BoxSpecification
    var members: [ObjectId]
    var members_id: [UUID]
//    var messages: [Messages]
}

enum MediaType: Int, Content {
    case png, text, jpg, mp4
}

enum BoxType: Int, Content {
    case privateChat, group
}
