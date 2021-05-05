//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 05/05/2021.
//

import Vapor

struct Avatar: Content {
    var file: Data?
}

enum SearchUserCases: String {
    case name
    case lastName
    case phoneNumber
    case email
    case dob
}
