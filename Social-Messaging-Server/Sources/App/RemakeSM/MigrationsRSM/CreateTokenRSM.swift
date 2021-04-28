//
//  CreateTokenRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Fluent

struct CreateTokenRSM: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokensrsm")
      .id()
      .field("value", .string, .required)
      .field("userID", .uuid, .required, .references("usersrsm", "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("tokensrsm").delete()
  }
}
