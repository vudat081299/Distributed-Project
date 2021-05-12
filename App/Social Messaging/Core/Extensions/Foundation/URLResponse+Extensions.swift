//
//  URLResponse+Extensions.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 12/05/2021.
//

import Foundation

extension URLResponse {
//    fileprivate var isSuccess: Bool {
    var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        return (200...299).contains(response.statusCode)
    }
}
