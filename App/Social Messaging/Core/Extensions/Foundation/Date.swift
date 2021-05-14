//
//  Date.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 14/05/2021.
//

import Foundation

extension Date {
    /// Get current seconds Timestamp - 10 digits
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
         /// Get the current millisecond timestamp - 13 bits
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
