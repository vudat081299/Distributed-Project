//
//  routesRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor

func routesRSM(_ app: Application) throws {

    let usersControllerRSM = UsersControllerRSM()
    try app.register(collection: usersControllerRSM)
    
    
    
    // MARK: - Web socket.
    app.webSocket("echo") { req, ws in
        // Connected WebSocket.
        print(ws)
    }
    
//    app.webSocket("socket", onUpgrade: webSocket)
    app.webSocket("socket") { req, ws in
        webSocket(req: req, socket: ws)
    }

    // create first web socket conection.
    app.webSocket("cfwscnt", ":userId") { req, ws in
        guard let userId = req.parameters.get("userId") else {
            return
        }
        print(userId)
        webSocket(req: req, socket: ws)
    }
}

func webSocket(req: Request, socket: WebSocket) {
    socket.onText { _, text in
        print(text)
    }
    
    socket.onClose.whenComplete { result in
        // Succeeded or failed to close.
        let wsOnCloseResult = result
        switch result {
        case .success:
            print("close ws successful!")
            break
        case .failure:
            print("close ws unsuccessful!")
            break
        }
        print(wsOnCloseResult)
        print("close ws")
    }
}
