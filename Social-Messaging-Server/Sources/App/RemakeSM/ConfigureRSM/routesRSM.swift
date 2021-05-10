//
//  routesRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor
import MongoKitten

func routesRSM(_ app: Application) throws {
    
    let usersControllerRSM = UsersControllerRSM()
    try app.register(collection: usersControllerRSM)
    
    let messagesController = MessagesController()
    try app.register(collection: messagesController)
    
    
    
    // MARK: - Web socket.
    app.webSocket("echo") { req, ws in
        // Connected WebSocket.
        print(ws)
    }
    
//    app.webSocket("socket", onUpgrade: webSocket)
    app.webSocket("socket") { req, ws in
        webSocketBehaviorHandler(req: req, socket: ws)
    }

    // create first web socket conection.
    app.webSocket("connecttowsserver", ":userId") { req, ws in
        guard let userId = req.parameters.get("userId") else {
            return
        }
        webSocketPerUserManager.add(ws: ws, to: userId)
        webSocketBehaviorHandler(req: req, socket: ws)
        
    }
}

func webSocketBehaviorHandler(req: Request, socket: WebSocket) {
    socket.onText { _, text in
        let jsonData = text.data(using: .utf8)!
        
        // sample to post in ws.
//        {
//            "boxId": "6094d82ddba87b2eb8b413f3",
//            "creationDate": 1620174174,
//            "text": "test text",
//            "fileId": "6094d82ddba87b2eb8b413f3",
//            "type": 1,
//            "sender_id": "6094d82ddba87b2eb8b413f3",
//            "senderIdOnRDBMS": "C15CF82B-2903-4C8C-975D-631976544998"
//        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let mess = try decoder.decode(CreateMessage.self, from: jsonData)
            
            
            // Save mess.
            let createMessageInBox = Message(
                creationDate: mess.creationDate,
                text: mess.text,
                boxId: mess.boxId,
                fileId: mess.fileId,
                type: mess.type,
                sender_id: mess.sender_id,
                senderIdOnRDBMS: mess.senderIdOnRDBMS
            )
            CoreEngine.mess(
                createMessageInBox,
                inDatabase: req.mongoDB
            )
            
//            CoreEngine.findBox(
//                id: mess.boxId,
//                inDatabase: req.mongoDB
//            ).map { box in
                webSocketPerUserManager.notifyMess(to: mess.members, content: createMessageInBox)
//            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    socket.onClose.whenComplete { result in
        // Succeeded or failed to close.
        let wsOnCloseResult = result
        switch result {
        case .success:
//            webSocketPerUserManager.dictionary
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

struct CreateMessage: Codable {
    let boxId: ObjectId
    let creationDate: Date
    let text: String?
    let fileId: ObjectId?
    let type: MediaType
    let sender_id: ObjectId
    let senderIdOnRDBMS: UUID
    
    let members: [UUID]
}
