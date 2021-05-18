//
//  TextModel.swift
//  MessageApp
//
//  Created by Vũ Quý Đạt  on 2/17/20.
//  Copyright © 2020 VU QUY DAT. All rights reserved.
//

import Foundation



// MARK: - Structure.
struct WSResolvedMessage: Codable {
    let type: WSResolvedMajorDataType
    let majorData: WSMessage
}

enum WSResolvedMajorDataType: Int, Codable {
    case notify, newMess, newBox, userTyping
}

struct WSMessage: Codable {
    let _id: String?
    let boxId: String? // _id
    let creationDate: Date
    let text: String?
    let fileId: String?
    let type: MediaTypeMess
    let senderId: String? // _id
    let senderIdOnRDBMS: UUID?
    let notify: String?
}

struct MessageSendWS: Codable {
    let type: WSResolvedMajorDataType
    let majorData: MajorDataSendWS
}

struct MajorDataSendWS: Codable {
    let boxId: String // _id
    let creationDate: String
    let text: String?
    let fileId: String?
    let type: MediaTypeMess
    let senderId: String // _id
    let senderIdOnRDBMS: UUID
    let members: [String]
}

struct ResolvedMessage: Codable {
    let _id: String?
    let creationDate: Date
    let text: String?
    let boxId: String
    let fileId: String?
    let type: Int
    let senderId: String
    let senderIdOnRDBMS: UUID
}







enum MediaTypeMess: Int, Codable {
    case png, text, jpg, mp4
}



// MARK: - From old project.
////MARK: Model.
//final class MessagerModel: Codable {
//    var userID: Int
//    var messageText: String
//    var timeSending: DateComponents
//
//    init(_ userID: Int, _ messageText: String) {
//        self.userID = userID
//        self.messageText = messageText
////        var dateComponents = DateComponents()
//        // get the current date and time
//        let currentDateTime = Date()
//
//        // get the user's calendar
//        let userCalendar = Calendar.current
//
//        // choose which date and time components are needed
//        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
//
//        // get the components
//        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
//
//        // now the components are available
////        dateTimeComponents.year   // 2016
////        dateTimeComponents.month  // 10
////        dateTimeComponents.day    // 8
////        dateTimeComponents.hour   // 22
////        dateTimeComponents.minute // 42
////        dateTimeComponents.second // 17
//        self.timeSending = dateTimeComponents
//    }
//}
//
//struct MessageUpload: Codable {
//    let time: String
//    let content: String
//    let roomID: Int
//    var from: String
//    var to: String
//}
//
//struct ResponseGetAllMessages: Codable {
//    let code: Int
//    let message: String
//    let data: [DataMessage]
//}
//
//struct DataMessage: Codable {
//    let time: String
//    let content: String
//    let roomID: Int
//    var from: String
//    var to: String
//}
