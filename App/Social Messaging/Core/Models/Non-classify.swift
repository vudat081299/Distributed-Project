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
    
    let creator_id: String?
    let createdAt: String
}

enum BoxType: Int, Codable {
    case privateChat, group
}
