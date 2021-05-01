////
////  AuthenticationMiddlewareSM.swift
////  
////
////  Created by Vũ Quý Đạt  on 25/04/2021.
////
//
//import Vapor
//
//struct AuthenticationMiddlewareSM: Middleware {
//    func respond(
//        to request: Request,
//        chainingTo next: Responder
//    ) -> EventLoopFuture<Response> {
//        // Get the first cookie's string value
//        guard let token = request.headers.cookie?.all.first?.value.string else {
//            return request.view.render("login").flatMap { view in
//                return view.encodeResponse(for: request)
//            }
//        }
//        
//        do {
//            // Only a valid token is needed
//            let accessToken = try request.application.jwtSM.verify(token, as: AccessTokenSM.self)
//            request.accessTokenSM = accessToken
//            
//            return next.respond(to: request)
//        } catch {
//            let response = request.redirect(to: "/")
//            response.cookies["server"] = .expired
//            
//            return request.eventLoop.makeSucceededFuture(response)
//        }
//    }
//}
//
//extension Request {
//    var accessTokenSM: AccessTokenSM? {
//        get {
//            return self.storage[TokenStorageKeySM.self]
//        }
//        set {
//            self.storage[TokenStorageKeySM.self] = newValue
//        }
//    }
//}
//
//private struct TokenStorageKeySM: StorageKey {
//    typealias Value = AccessTokenSM
//}
