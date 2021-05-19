//
//  Time.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 28/12/2020.
//

import Foundation

class Time {
    var currentDateTime: Date!
    var userCalendar: Calendar!
    var requestedComponents: Set<Calendar.Component>
    var dateTimeComponents: DateComponents
    static var iso8601String: String {
        get {
            // Date with ISO 8601 format.
            let dateFormatter = DateFormatter()
//            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
//            dateFormatter.locale = enUSPosixLocale
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss SSSZ"
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZSSS"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let iso8601String = dateFormatter.string(from: Date())
            return iso8601String
        }
    }
    
    let formatter: DateFormatter
    static var someOtherDateTime: Date {
        get {
            return Date(timeIntervalSinceReferenceDate: -123456789.0) // Feb 2, 1997, 10:26 AM
        }
    }
    static var currentTimeString: String {
        get {
            var dateTimeNow: Date!
            dateTimeNow = Date()
            let formatTime: DateFormatter
            formatTime = DateFormatter()
            formatTime.timeStyle = .medium
            formatTime.dateStyle = .long
            formatTime.string(from: dateTimeNow)
            return formatTime.string(from: dateTimeNow)
        }
    }
    
    enum DateType: Int {
        case date
        case time
        case datetime
    }
    
    static func getTypeWithFormat(of date: Date, type: DateType) -> String {
        switch type {
        case .date:
            
            let customFormatter = DateFormatter()
            customFormatter.timeStyle = .none
            customFormatter.dateStyle = .medium
            return customFormatter.string(from: date)
            break
        case .time:
            
            let customFormatter = DateFormatter()
            customFormatter.timeStyle = .short
            customFormatter.dateStyle = .none
            return customFormatter.string(from: date)
            break
        case .datetime:
            return ""
            break
        }
    }
    
    static func iso8601String(of date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZSSS"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: date)
    }
    
    init() {

        // get current date time
        // method 1
        // get the current date and time
        self.currentDateTime = Date()

        // get the user's calendar
        self.userCalendar = Calendar.current

        // choose which date and time components are needed
        self.requestedComponents = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]

        // get the components
        dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)

        // now the components are available
//        dateTimeComponents.year   // 2016
//        dateTimeComponents.month  // 10
//        dateTimeComponents.day    // 8
//        dateTimeComponents.hour   // 22
//        dateTimeComponents.minute // 42
//        dateTimeComponents.second // 17
        
        // method 2
        // get the current date and time
//        self.currentDateTime = Date()

        // initialize the date formatter and set the style
        formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long

        // get the date time String from the date object
        formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
        
        // usage
        // "10/8/16, 10:52 PM"
//        formatter.timeStyle = .short
//        formatter.dateStyle = .short
//        formatter.string(from: currentDateTime)
//
//        // "Oct 8, 2016, 10:52:30 PM"
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .medium
//        formatter.string(from: currentDateTime)
//
//        // "October 8, 2016 at 10:52:30 PM GMT+8"
//        formatter.timeStyle = .long
//        formatter.dateStyle = .long
//        formatter.string(from: currentDateTime)
//
//        // "October 8, 2016"
//        formatter.timeStyle = .none
//        formatter.dateStyle = .long
//        formatter.string(from: currentDateTime)
//
//        // "10:52:30 PM"
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .none
//        formatter.string(from: currentDateTime)
        
        
        
        // creating your own date and time
        // method 1
//        Time.currentDateTime = Date()
//        Date().timeIntervalSinceReferenceDate
        
        // method 2
        // Specify date components
//        var dateComponents = DateComponents()
//        dateComponents.year = 1980
//        dateComponents.month = 7
//        dateComponents.day = 11
//        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
//        dateComponents.hour = 8
//        dateComponents.minute = 34

        // Create date from components
//        let userCalendar = Calendar.current // user calendar
//        let someDateTime = userCalendar.date(from: dateComponents)
        
        // method 3
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        let someDateTime = formatter.date(from: "2016/10/08 22:31")
        
        
        
    }
}
