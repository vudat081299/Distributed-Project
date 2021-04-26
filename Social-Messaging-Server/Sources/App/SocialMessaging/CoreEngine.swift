//
//  CoreEngine.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor
import MongoKitten

struct CoreEngine {
    
    static func findUser(
        byUsername username: String,
        inDatabase database: MongoDatabase
    ) -> EventLoopFuture<UserSM?> {
        return database[UserSM.collection].findOne(
            "credentials.username" == username,
            as: UserSM.self
        )
    }
    
    
    
}
