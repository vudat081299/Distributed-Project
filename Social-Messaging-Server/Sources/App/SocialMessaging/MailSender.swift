////
////  File.swift
////  
////
////  Created by Dat vu on 28/04/2021.
////
//
//import Vapor
//import VaporSMTPKit
//import SMTPKitten
//
//extension SMTPCredentials {
//    static var `default`: SMTPCredentials {
//        return SMTPCredentials(
//            hostname: "smtp.gmail.com",
//            ssl: .startTLS(configuration: .default),
//            email: "vudat081299@gmail.com",
//            password: "Iviundhacthi8987g"
//        )
//    }
//}
//
//func sendEmail(_ req: Request) throws -> EventLoopFuture<String> {
//    let email = Mail(
//        from: "vudat081299@gmail.com",
//        to: [
//            MailUser(name: "Myself", email: "vudat81299@gmail.com")
//        ],
//        subject: "Your new mail server!",
//        contentType: .html,
//        text: ""
//    )
//    
//    return req.application.sendMail(email, withCredentials: .default).map {
//        return "Check your mail!"
//    }
//}
