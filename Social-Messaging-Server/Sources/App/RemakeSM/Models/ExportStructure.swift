//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 05/05/2021.
//

import Vapor
import MongoKitten

struct Avatar: Content {
    var file: Data?
}

enum SearchUserCases: String {
    case idOnRDBMS
    case name
    case lastName
    case phoneNumber
    case email
    case dob
}

struct FollowUserPostRQ: Content {
    let userObjectId: ObjectId
    let followerObjectId: ObjectId
}

struct FileUpload: Content {
    var fileObjectId: String?
    var file: Data?
}

struct UpdateAuthUserProfile: Content {
    let data: String?
    let field: String?
}
