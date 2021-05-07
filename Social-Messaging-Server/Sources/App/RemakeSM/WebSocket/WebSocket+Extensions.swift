//
//  WebSocket+Extensions.swift
//  App
//
//  Created by Vu Quy Dat on 15/12/2020.
//

import Vapor
import Foundation

extension WebSocket {
    func send(_ content: Message) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(content) else { return }
        
        // Convert data to array of bits.
//        let bytess = data.withUnsafeBytes {
//            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
//        }
        
        send(raw: data, opcode: .text, fin: false)
    }
}
