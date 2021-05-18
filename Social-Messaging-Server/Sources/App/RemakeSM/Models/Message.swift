//
//  MessageRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor
import MongoKitten

struct Message: Codable, Content {
    static let collection = "messages"
    
    let _id: ObjectId
    let creationDate: Date
    let text: String?
    let boxId: ObjectId
    let fileId: ObjectId?
    let type: MediaType?
    let senderId: ObjectId
    let senderIdOnRDBMS: UUID?
}

struct ResolvedMessageRSM: Codable {
    let _id: ObjectId
    let box: Box
    let text: String
    let creationDate: Date
    let fileId: ObjectId?
    let sender: UserRSM
}

struct CreateMessageRSM: Codable {
    let text: String
    let file: Data?
}
