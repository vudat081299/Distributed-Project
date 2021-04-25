//
//  JWTSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import JWTKit
import Vapor
import MongoKitten

struct AccessTokenSM: JWTPayload {
    let expiration: ExpirationClaim
    let subject: ObjectId
    
    init(subject: UserMongoDB) {
        // Expires in 24 hours
//        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(24 * 3600))
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(10 * 60))
        self.subject = subject._id
    }
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

extension Application {
    var jwtSM: JWTSigner {
        // Generate a random key and use that on production/
        // If this key is known by attackers, they can impersonate all users
        return JWTSigner.hs512(
            key: Array("yoursupersecretsecuritykey".utf8)
        )
    }
}
