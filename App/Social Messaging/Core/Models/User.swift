//
//  User.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 27/12/2020.
//

import Foundation

final class User: Codable {
    var code: Int
    var message: String
    var data: [UserData]
    
    init(code: Int, message: String, data: [UserData]) {
        self.code = code
        self.message = message
        self.data = data
    }
}

struct UserData: Codable {
    let id: String
    let name: String
    let username: String
    let email: String?
    let phonenumber: String?
    let idDevice: String?
}
