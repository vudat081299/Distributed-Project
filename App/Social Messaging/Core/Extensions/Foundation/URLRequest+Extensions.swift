//
//  URLRequest+Extensions.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 12/05/2021.
//

import Foundation

extension URLRequest {
  mutating func addJSONBody<C: Codable>(_ object: C) throws {
    let encoder = JSONEncoder()
    httpBody = try encoder.encode(object)
    setValue("application/json", forHTTPHeaderField: "Content-Type")
  }
}
