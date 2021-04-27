//
//  routesSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor



// MARK: - Route.
func routesSM(_ app: Application) throws {
    
    let userControllerSM = UserControllerSM()
    try app.register(collection: userControllerSM)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    app.post("login") { request -> EventLoopFuture<Response> in
        let credentials = try request.content.decode(CredentialsSM.self)
        
        return CoreEngine.findUser(
            byUsername: credentials.username,
            inDatabase: request.mongoDBSM
        ).flatMap { user -> EventLoopFuture<Response> in
            do {
                guard
                    let user = user,
                    try user.credentials.matchesPassword(credentials.password)
                else {
                    return request.view.render("MongoDB/loginMongoDB", [
                        "error": "Incorrect credentials"
                    ]).flatMap { view in
                        return view.encodeResponse(for: request)
                    }
                }
                
                let accessToken = AccessTokenSM(subject: user)
                let token = try request.application.jwtSM.sign(accessToken)
                
                let response = Response(status: .accepted, version: HTTPVersion(major: 3, minor: 3), headers: HTTPHeaders(), body: Response.Body(string: "Hello, world!"))
                
//                var cookie = HTTPCookies.Value(string: token)
//                cookie.expires = accessToken.expiration.value
//                response.cookies["server"] = cookie
                return request.eventLoop.makeSucceededFuture(response)
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    app.post("signup") { request -> EventLoopFuture<Response> in
        let credentials = try request.content.decode(CredentialsSM.self)
        
        return CoreEngine.findUser(
            byUsername: credentials.username,
            inDatabase: request.mongoDBSM
        ).flatMap { user -> EventLoopFuture<Response> in
            do {
                guard
                    let user = user,
                    try user.credentials.matchesPassword(credentials.password)
                else {
                    return request.view.render("MongoDB/loginMongoDB", [
                        "error": "Incorrect credentials"
                    ]).flatMap { view in
                        return view.encodeResponse(for: request)
                    }
                }
                
                let accessToken = AccessTokenSM(subject: user)
                let token = try request.application.jwtSM.sign(accessToken)
                
                let response = Response(status: .accepted, version: HTTPVersion(major: 3, minor: 3), headers: HTTPHeaders(), body: Response.Body(string: "Hello, world!"))
                
//                var cookie = HTTPCookies.Value(string: token)
//                cookie.expires = accessToken.expiration.value
//                response.cookies["server"] = cookie
                return request.eventLoop.makeSucceededFuture(response)
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
}
