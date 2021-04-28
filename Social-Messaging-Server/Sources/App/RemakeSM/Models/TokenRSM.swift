//
//  TokenRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor
import Fluent

final class TokenRSM: Model, Content {
  static let schema = "tokensrsm"

  @ID
  var id: UUID?

  @Field(key: "value")
  var value: String

  @Parent(key: "userID")
  var user: UserRSM

  init() {}

  init(id: UUID? = nil, value: String, userID: UserRSM.IDValue) {
    self.id = id
    self.value = value
    self.$user.id = userID
  }
}

extension TokenRSM {
  static func generate(for user: UserRSM) throws -> TokenRSM {
    let random = [UInt8].random(count: 16).base64
    return try TokenRSM(value: random, userID: user.requireID())
  }
}

extension TokenRSM: ModelTokenAuthenticatable {
  static let valueKey = \TokenRSM.$value
  static let userKey = \TokenRSM.$user
  typealias UserRSM = App.UserRSM
  var isValid: Bool {
    true
  }
}
