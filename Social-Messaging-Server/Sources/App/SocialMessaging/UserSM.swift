//
//  UserSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import MongoKitten
import Vapor

struct UserProfileSM: Codable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let dateOfBirth: String
    let bio: String
}

struct CredentialsSM: Codable {
    let username: String
    
    // When sent by an HTTP request, this password is unhashed
    let password: String
}

struct EncryptedCredentialsSM: Codable {
    let username: String
    
    // When stored in MongoDB, it is hashed using BCrypt
    let hashedPassword: String
    
    public init(hashing credentials: CredentialsSM) throws {
        self.username = credentials.username
        self.hashedPassword = try BCryptDigest().hash(credentials.password)
    }
    
    public init(username: String, password: String) throws {
        self.username = username
        self.hashedPassword = try BCryptDigest().hash(password)
    }
    
    public func matchesPassword(_ password: String) throws -> Bool {
        return try BCryptDigest().verify(password, created: self.hashedPassword)
    }
}

struct UserSM: Codable {
    static let collection = "users"

    let _id: ObjectId
    let profile: UserProfileSM
    let credentials: EncryptedCredentialsSM
    var following: [ObjectId]
    var followers: [ObjectId]
}
