//
//  Data+Extensions..swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 12/05/2021.
//

import Foundation

extension Data {
//    fileprivate func decode<D: Decodable>(_ type: D.Type) throws -> D {
    func decode<D: Decodable>(_ type: D.Type) throws -> D {
        let decoder = JSONDecoder()
        return try decoder.decode(D.self, from: self)
    }
}
