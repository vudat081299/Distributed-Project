//
//  Token.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 24/12/2020.
//

import Foundation

final class Token: Codable {
    var id: String
    var createdAt: Date
    var value: String
    var user: ResolvedUserId
    
    init(id: String, createdAt: Date, value: String, user: ResolvedUserId) {
        self.id = id
        self.createdAt = createdAt
        self.value = value
        self.user = user
    }
}

struct ResolvedUserId: Codable {
    let id: UUID
}
