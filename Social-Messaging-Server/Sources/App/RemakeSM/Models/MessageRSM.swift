//
//  MessageRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Foundation
import Vapor
import MongoKitten

struct MessageRSM: Codable {
    static let collection = "messagersm"
    
    let _id: ObjectId
    let box: ObjectId
    let text: String
    let creationDate: Date
    let fileId: ObjectId?
    let sender: UUID
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
