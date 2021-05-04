//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Fluent
import Vapor

final class UserRSM: Model, Content {
    static let schema = "usersrsm"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String

    @Field(key: "password")
    var password: String
    
    
    
    // MARK: - .
    @Field(key: "lastName")
    var lastName: String?
    
    @Field(key: "phoneNumber")
    var phoneNumber: String?
    
    @Field(key: "email")
    var email: String?
    
    @Field(key: "dob")
    var dob: String?
    
    @Field(key: "bio")
    var bio: String?
    
    @Field(key: "profilePicture")
    var profilePicture: String?
    
    @Field(key: "idDevice")
    var idDevice: String?
    
    @Field(key: "otp")
    var otp: String?
    
    @Field(key: "tsotp")
    var tsotp: String?
    
    
    
    // MARK: - .
    @Field(key: "gender")
    var gender: Gender?

    @Field(key: "privacy")
    var privacy: Privacy?
    
    @Field(key: "defaultAvartar")
    var defaultAvartar: DefaultAvartar?
    
//    @Timestamp(key: "created_at", on: .create)
//    var createdAt: Date?

    
    
    init() {}
    
    init(id: UUID? = nil,

         name: String,
         username: String,
         password: String,
         
         lastName: String? = nil,
         phoneNumber: String? = nil,
         email: String? = nil,
         dob: String? = nil,
         bio: String? = nil,
         profilePicture: String? = nil,
         idDevice: String? = nil,
         otp: String? = nil,
         tsotp: String? = nil,
         
         gender: Gender? = .nonee,
         privacy: Privacy = .publicState,
         defaultAvartar: DefaultAvartar = .nonee
    ) {
        self.name = name
        self.username = username
        self.password = password
        
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.dob = dob
        self.bio = bio
        self.profilePicture = profilePicture
        self.idDevice = idDevice
        self.otp = otp
        self.tsotp = tsotp

        self.gender = gender
        self.privacy = privacy
        self.defaultAvartar = defaultAvartar
    }
    
    
    
    // MARK: - Public info.
    final class Public: Content {
        var id: UUID?
        var name: String
        var username: String
        
        var lastName: String?
        var phoneNumber: String?
        var email: String?
        var dob: String?
        var bio: String?
        var profilePicture: String?
        var idDevice: String?
        
        var gender: Gender?
        var privacy: Privacy?
        var defaultAvartar: DefaultAvartar?
        
        init(id: UUID?,
             name: String,
             username: String,
             
             lastName: String? = nil,
             phoneNumber: String? = nil,
             email: String? = nil,
             dob: String? = nil,
             bio: String? = nil,
             profilePicture: String? = nil,
             idDevice: String? = nil,
             
             gender: Gender? = nil,
             privacy: Privacy? = nil,
             defaultAvartar: DefaultAvartar? = nil
        ) {
            self.id = id
            self.name = name
            self.username = username
            
            self.lastName = lastName
            self.phoneNumber = phoneNumber
            self.email = email
            self.dob = dob
            self.bio = bio
            self.privacy = privacy
            self.idDevice = idDevice
            
            self.gender = gender
            self.defaultAvartar = defaultAvartar
            self.profilePicture = profilePicture
        }
    }
}

struct UpdateUserRSM: Content {
    let name: String
    let username: String
    
    let lastName: String?
    let phoneNumber: String?
    let email: String?
    let dob: String?
    let bio: String?
    let profilePicture: String?
    let idDevice: String?
    
    let gender: Gender?
    let privacy: Privacy?
    let defaultAvartar: DefaultAvartar?
}

extension UserRSM {
    func convertToPublic() -> UserRSM.Public {
        return UserRSM.Public(id: id,
                              name: name,
                              username: username,
                              
                              lastName: lastName,
                              phoneNumber: phoneNumber,
                              email: email,
                              dob: dob,
                              bio: bio,
                              profilePicture: profilePicture,
                              idDevice: idDevice,
                              
                              gender: gender,
                              privacy: privacy,
                              defaultAvartar: defaultAvartar
        )
    }
}

extension EventLoopFuture where Value: UserRSM {
    func convertToPublicRSM() -> EventLoopFuture<UserRSM.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}

extension Collection where Element: UserRSM {
    func convertToPublicRSM() -> [UserRSM.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<UserRSM> {
    func convertToPublicRSM() -> EventLoopFuture<[UserRSM.Public]> {
        return self.map { $0.convertToPublicRSM() }
    }
}

extension UserRSM: ModelAuthenticatable {
    static let usernameKey = \UserRSM.$username
    static let passwordHashKey = \UserRSM.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension UserRSM: ModelSessionAuthenticatable {}
extension UserRSM: ModelCredentialsAuthenticatable {}



// MARK: - Enumeration.
enum Privacy: Int, Content {
    case publicState, privateState
}

enum Gender: Int, Content {
    case male, female, other, nonee
}

enum DefaultAvartar: Int, Content {
    case engineer, pianist, male, female, other, nonee
}
