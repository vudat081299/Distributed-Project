////
////  AppSM.swift
////  
////
////  Created by Vũ Quý Đạt  on 25/04/2021.
////
//
//import Vapor
//
//
//
//// MARK: - App.
//public func makeSMApp() throws -> Application {
//    let app = Application()
//    try configureSM(app)
//    
//
//    
////    a() {
////        print("11111")
////    } c: {
////        print("22222")
////    }()
//    
//    return app
//}
//
//func a (b: @escaping () -> (), c: @escaping () -> ()) -> (() -> ()) {
//    b()
//    c()
//    return { print("33333") }
//}
//
//
//
//// MARK: - Context.
//
//
//
////extension Application {
////    public func sendMail(
////        _ mail: Mail,
////        withCredentials credentials: SMTPCredentials,
////        preventedDomains: Set<String> = ["example.com"]
////    ) -> EventLoopFuture<Void> {
////        return sendMails([mail], withCredentials: credentials, preventedDomains: preventedDomains)
////    }
////
////    public func sendMails(
////        _ mails: [Mail],
////        withCredentials credentials: SMTPCredentials,
////        preventedDomains: Set<String> = ["example.com"]
////    ) -> EventLoopFuture<Void> {
////        func filterMailAddress(_ address: MailUser) -> Bool {
////            for domain in preventedDomains {
////                if address.email.contains(domain) {
////                    return false
////                }
////            }
////
////            return true
////        }
////
////        let mails = mails.compactMap { mail -> Mail? in
////            var mail = mail
////
////            mail.to = mail.to.filter(filterMailAddress)
////            mail.cc = mail.cc.filter(filterMailAddress)
////            mail.bcc = mail.bcc.filter(filterMailAddress)
////
////            if mail.to.isEmpty {
////                return nil
////            }
////
////            return mail
////        }
////
////
////        return SMTPClient.connect(
////            hostname: credentials.hostname,
////            port: credentials.port,
////            ssl: credentials.ssl,
////            eventLoop: self.eventLoopGroup.next()
////        ).flatMap { client in
////            client.login(
////                user: credentials.email,
////                password: credentials.password
////            ).flatMap {
////                let sent = mails.map(client.sendMail)
////                return EventLoopFuture.andAllSucceed(sent, on: self.eventLoopGroup.next())
////            }
////        }
////    }
////}
////
////public struct SMTPCredentials {
////    let hostname: String
////    let port: Int
////    let email: String
////    let ssl: SMTPSSLMode
////    let password: String
////
////    public init(
////        hostname: String,
////        port: Int = 587,
////        ssl: SMTPSSLMode,
////        email: String,
////        password: String
////    ) {
////        self.hostname = hostname
////        self.port = port
////        self.ssl = ssl
////        self.email = email
////        self.password = password
////    }
////}
