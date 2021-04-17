// Change file name to User.swift to use.



//    Copyright (c) 2020 Razeware LLC
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without
//    restriction, including without limitation the rights to use,
//    copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom
//    the Software is furnished to do so, subject to the following
//    conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    Notwithstanding the foregoing, you may not use, copy, modify,
//    merge, publish, distribute, sublicense, create a derivative work,
//    and/or sell copies of the Software in any work that is designed,
//    intended, or marketed for pedagogical or instructional purposes
//    related to programming, coding, application development, or
//    information technology. Permission for such use, copying,
//    modification, merger, publication, distribution, sublicensing,
//    creation of derivative works, or sale is expressly withheld.
//
//    This project and source code may use libraries or frameworks
//    that are released under various Open-Source licenses. Use of
//    those libraries and frameworks are governed by their own
//    individual licenses.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//    DEALINGS IN THE SOFTWARE.

import MongoKitten
import Vapor

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
}

struct Credentials: Codable {
    let username: String
    
    // When sent by an HTTP request, this password is unhashed
    let password: String
}

struct EncryptedCredentials: Codable {
    let username: String
    
    // When stored in MongoDB, it is hashed using BCrypt
    let hashedPassword: String
    
    public init(hashing credentials: Credentials) throws {
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

struct UserMongoDB: Codable {
    static let collection = "users"

    let _id: ObjectId
    let profile: UserProfile
    let credentials: EncryptedCredentials
    var following: [ObjectId]
}
