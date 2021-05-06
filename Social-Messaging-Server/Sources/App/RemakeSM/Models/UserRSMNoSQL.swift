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
    
    // Should separate otp to a RDBMS table in future.
    var otp: String?
    var tsotp: String?
    
    var gender: Gender?
}

struct UserRSMNoSQL: Codable, Content {
    static let collection = "usersrsmnosql"

    let _id: ObjectId
    let idOnRDBMS: UUID
    
    var name: String
    var username: String
    
    var lastName: String?
    var bio: String?
    var profilePicture: ObjectId?
    
    var privacy: Privacy?
    var defaultAvartar: DefaultAvartar?
    var personalData: PersonalData?
    
    var followers: [ObjectId]
    var followings: [ObjectId]
    var boxes: [ObjectId]
    
    func convertToPublicData() -> UserRSMNoSQLPublic {
        return UserRSMNoSQLPublic(_id: _id,
                                  idOnRDBMS: idOnRDBMS,
                                  
                                  name: name,
                                  username: username,
                                  
                                  lastName: lastName,
                                  bio: bio,
                                  profilePicture: profilePicture,
                                  
                                  privacy: privacy,
                                  defaultAvartar: defaultAvartar
//                                  personalData: personalData,

//                                  followers: followers,
//                                  followings: followings,
//                                  boxes: boxes
        )
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
    let idOnRDBMS: UUID
    
    let name: String
    let username: String
    
    let lastName: String?
    let bio: String?
    let profilePicture: ObjectId?
    
    let privacy: Privacy?
    let defaultAvartar: DefaultAvartar?
//    let personalData: PersonalData?
    
//    let followers: [ObjectId]
//    let followings: [ObjectId]
//    let boxes: [ObjectId]
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
    var profilePicture: ObjectId?
    var idDevice: String?
    
    var gender: Gender?
    var privacy: Privacy?
    var defaultAvartar: DefaultAvartar?
}



//
// time handler
func returnDistanceTime(distanceTime: TimeInterval) -> String{

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: Date())
}

func getCreationTimeInt(dateString : String) -> String{

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//    dateFormatter.timeZone = TimeZone.systemTimeZone()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    let time = dateFormatter.date(from: dateString)?.timeIntervalSince1970

    let distanceTime = NSDate().timeIntervalSince1970 - time!

    let stringTime = returnDistanceTime(distanceTime: distanceTime)

    print("**** The time \(stringTime)", terminator: "")

    return stringTime

}

//getCreationTimeInt("2016-03-01 12:12:12")
