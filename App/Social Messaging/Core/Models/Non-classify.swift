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
    let lastestUpdate: String
}

struct UpdateAuthUserProfile: Codable {
    let data: String
    let field: String
}
