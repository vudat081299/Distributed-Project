////
////  Message.swift
////  
////
////  Created by Vũ Quý Đạt  on 25/04/2021.
////
//
//import Foundation
//import Vapor
//import MongoKitten
//
//struct Message: Codable {
//    static let collection = "message"
//    
//    let _id: ObjectId
//    let text: String
//    let creationDate: Date
//    let fileId: ObjectId?
//    let creator: ObjectId
//}
//
//struct ResolvedMessage: Codable {
//    let _id: ObjectId
//    let text: String
//    let creationDate: Date
//    let fileId: ObjectId?
//    let creator: UserSM
//}
//
//struct CreateMessage: Codable {
//    let text: String
//    let file: Data?
//}
