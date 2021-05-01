//
//  UserRSMNoSQL.swift
//  
//
//  Created by Vũ Quý Đạt  on 30/04/2021.
//

import Vapor
import MongoKitten

struct PersonalData: Codable {
    var phoneNumber: String?
    var email: String?
    var dob: String?
    var idDevice: String?
    var block: [ObjectId]
}

struct UserRSMNoSQL: Codable, Content {
    static let collection = "usersrsmnosql"

    let _id: ObjectId
    let idOnRDBMS: UUID
    
    var name: String
    var username: String
    
    var lastName: String?
    var bio: String?
    var privacy: Privacy?
    var profilePicture: String?
    var personalData: PersonalData?
    
    var following: [ObjectId]
    var box: [ObjectId]
    
    func convertToPublicData() -> UserRSMNoSQLPublic {
        return UserRSMNoSQLPublic(_id: _id, personalData: personalData, idOnRDBMS: idOnRDBMS, name: name, username: username, lastName: lastName, bio: bio, privacy: privacy, profilePicture: profilePicture, following: following, box: box)
    }
}

extension Collection where Element == UserRSMNoSQL {
  func convertToPublicData() -> [UserRSMNoSQLPublic] {
    return self.map { $0.convertToPublicData() }
  }
}

extension EventLoopFuture where Value == Array<UserRSMNoSQL> {
  func convertToPublicData() -> EventLoopFuture<[UserRSMNoSQLPublic]> {
    return self.map { $0.convertToPublicData() }
  }
}

struct UserRSMNoSQLPublic: Codable, Content {
    let _id: ObjectId
    let personalData: PersonalData?
    
    let idOnRDBMS: UUID
    
    let name: String
    let username: String
    
    let lastName: String?
    let bio: String?
    let privacy: Privacy?
    let profilePicture: String?
    
    let following: [ObjectId]
    let box: [ObjectId]
}

struct CreateUserRSMNoSQL: Codable {
    var idOnRDBMS: UUID?
    
    var name: String
    var username: String
    
    var lastName: String?
    var phoneNumber: String?
    var email: String?
    var dob: String?
    var bio: String?
    var privacy: Privacy?
    var profilePicture: String?
    var idDevice: String?
}
