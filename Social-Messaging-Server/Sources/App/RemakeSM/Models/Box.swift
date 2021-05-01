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
}

struct Box: Codable {
    static let collection = "boxs"

    let _id: ObjectId
    let creator: ObjectId
    let boxSpecification: BoxSpecification
    var members: [ObjectId]
    var messages: [CreateMessageInBox]
}

struct CreateMessageInBox: Codable {
    let text: String?
    let creationDate: Date
    let fileId: ObjectId?
//    let type: MediaType?
    let sender: UUID
}

enum MediaType: String {
    case png, text, jpg, mp4
}
