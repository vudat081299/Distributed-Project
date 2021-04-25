//
//  AuthenticationMiddlewareSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor

struct AuthenticationMiddlewareSM: Middleware {
    func respond(
        to request: Request,
        chainingTo next: Responder
    ) -> EventLoopFuture<Response> {
        // Get the first cookie's string value
        guard let token = request.headers.cookie?.all.first?.value.string else {
            return request.view.render("login").flatMap { view in
                return view.encodeResponse(for: request)
            }
        }
        
        do {
            // Only a valid token is needed
            let accessToken = try request.application.jwt.verify(token, as: AccessToken.self)
            request.accessToken = accessToken
            
            return next.respond(to: request)
        } catch {
            let response = request.redirect(to: "/")
            response.cookies["server"] = .expired
            
            return request.eventLoop.makeSucceededFuture(response)
        }
    }
}

extension Request {
    var accessTokenSM: AccessToken? {
        get {
            return self.storage[TokenStorageKey.self]
        }
        set {
            self.storage[TokenStorageKey.self] = newValue
        }
    }
}

private struct TokenStorageKeySM: StorageKey {
    typealias Value = AccessToken
}
