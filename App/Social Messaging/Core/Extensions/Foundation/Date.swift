//
//  Date.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 14/05/2021.
//

import Foundation

extension Date {
    /// Get current seconds Timestamp - 10 digits
    var timeStampString : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
         /// Get the current millisecond timestamp - 13 bits
    var milliStampString : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    /// Get current time with  iso8601 format in  String.
    var iso8601String: String {
        // Date with ISO 8601 format.
        let dateFormatter = DateFormatter()
//            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
//            dateFormatter.locale = enUSPosixLocale
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss SSSZ"
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZSSS"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let iso8601String = dateFormatter.string(from: self)
        return iso8601String
    }
    var iso8601StringShortTime: String {
        // Date with ISO 8601 format.
        let dateFormatter = DateFormatter()
//            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
//            dateFormatter.locale = enUSPosixLocale
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss SSSZ"
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZSSS"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let iso8601String = dateFormatter.string(from: self)
        return iso8601String
    }
    
    /// Example: May 10, 8:30 AM.
    var iso8601StringShortDateTime: String {
        // Date with ISO 8601 format.
        let dateFormatter = DateFormatter()
//            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
//            dateFormatter.locale = enUSPosixLocale
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss SSSZ"
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.dateFormat = "MM dd"
        dateFormatter.dateFormat = "MMMM dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let iso8601String = dateFormatter.string(from: self)
        return iso8601String
    }
}
