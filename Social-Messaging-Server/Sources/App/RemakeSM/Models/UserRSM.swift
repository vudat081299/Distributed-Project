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
    
    
    
    // MARK: -
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
    
    @Field(key: "privacy")
    var privacy: Privacy?
    
    @Field(key: "profilePicture")
    var profilePicture: String?
    
    @Field(key: "idDevice")
    var idDevice: String?
    

    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String, password: String,
         lastName: String? = nil, phoneNumber: String? = nil, email: String? = nil,
         dob: String? = nil, bio: String? = nil, privacy: Privacy = .publicState,
         profilePicture: String? = nil, idDevice: String? = nil
    ) {
        self.name = name
        self.username = username
        self.password = password
        
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.dob = dob
        self.bio = bio
        self.privacy = privacy
        self.profilePicture = profilePicture
        self.idDevice = idDevice
    }
    
    final class Public: Content {
        var id: UUID?
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
        
        init(id: UUID?, name: String, username: String,
             lastName: String? = nil, phoneNumber: String? = nil, email: String? = nil,
             dob: String? = nil, bio: String? = nil, privacy: Privacy? = nil,
             profilePicture: String? = nil, idDevice: String? = nil
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
            self.profilePicture = profilePicture
            self.idDevice = idDevice
        }
    }
}

extension UserRSM {
    func convertToPublic() -> UserRSM.Public {
        return UserRSM.Public(id: id, name: name, username: username,
                           lastName: lastName, phoneNumber: phoneNumber, email: email,
                           dob: dob, bio: bio, privacy: privacy, profilePicture: profilePicture,
                           idDevice: idDevice)
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



enum Privacy: String, Content {
    case publicState, privateState
}
