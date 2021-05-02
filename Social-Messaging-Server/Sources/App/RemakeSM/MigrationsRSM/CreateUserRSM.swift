//
//  CreateUserRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Fluent

struct CreateUserRSM: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("usersrsm")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .field("password", .string, .required)
            
            .field("lastName", .string)
            .field("phoneNumber", .string)
            .field("email", .string)
            .field("dob", .string)
            .field("gender", .string)
            .field("bio", .string)
            .field("privacy", .string)
            .field("defaultAvartar", .string)
            .field("profilePicture", .string)
            .field("idDevice", .string)
            .field("otp", .string)
            .field("tsotp", .string)
            
            
            .unique(on: "phoneNumber")
            .unique(on: "email")
            .unique(on: "idDevice")
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("usersrsm").delete()
    }
}
