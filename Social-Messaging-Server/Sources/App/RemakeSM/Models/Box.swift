//
//  Box.swift
//  
//
//  Created by Dat vu on 29/04/2021.
//

import MongoKitten
import Vapor

struct BoxSpecification: Codable {
    let name: String
    let avartar: ObjectId?
}

struct Box: Codable {
    static let collection = "boxs"

    let _id: ObjectId
    let boxSpecification: BoxSpecification
    var members: [UUID]
}
