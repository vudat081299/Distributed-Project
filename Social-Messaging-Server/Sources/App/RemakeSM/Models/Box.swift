//
//  Box.swift
//  
//
//  Created by Dat vu on 29/04/2021.
//

import Vapor
import MongoKitten

struct BoxSpecification: Codable {
    let name: String?
    let avartar: ObjectId?
    let creator: ObjectId
    let createAt: Date
}

struct Box: Codable {
    static let collection = "boxes"

    let _id: ObjectId
    let boxSpecification: BoxSpecification
    var members: [ObjectId]
    var messages: [CreateMessageInBox]
}

struct CreateMessageInBox: Codable {
    let creationDate: Date
    let text: String?
    let fileId: ObjectId?
//    let type: MediaType?
    let sender_id: ObjectId
    let senderIdOnRDBMS: UUID
}

enum MediaType: String {
    case png, text, jpg, mp4
}
