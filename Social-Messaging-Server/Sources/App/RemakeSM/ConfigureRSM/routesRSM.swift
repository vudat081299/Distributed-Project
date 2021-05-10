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
    
//    app.webSocket("socket") { req, ws in
//        webSocketBehaviorHandler(req: req, socket: ws, of: <#String#>)
//    }

    // create first web socket conection.
    app.webSocket("connecttowsserver", ":userId") { req, ws in
        guard let userId = req.parameters.get("userId") else {
            return
        }
        webSocketPerUserManager.add(ws: ws, to: userId)
        webSocketBehaviorHandler(req: req, socket: ws, of: userId)
        
    }
}

func webSocketBehaviorHandler(req: Request, socket: WebSocket, of userId: String) {
    socket.onText { _, text in
        let jsonData = text.data(using: .utf8)!
        
        // sample to post in ws.
//        {
//            "type": 0,
//            "data": "{\"boxId\": \"6097a490021b77cd7434dd2e\", \"creationDate\": 1620184184.11111111111111, \"text\": \"********************************\", \"fileId\": \"6094d82ddba87b2eb8b413f3\", \"type\": 3, \"sender_id\": \"6094d82ddba87b2eb8b413f3\", \"senderIdOnRDBMS\": \"C697A624-052D-48F3-9FB9-C823BDD246D7\", \"members\": [\"DBD54018-97DA-4888-B87A-D2E8403A9845\", \"C697A624-052D-48F3-9FB9-C823BDD246D7\"]}"
//        }
        
        // new design.
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let resolvedData = try decoder.decode(ResolvedWSData.self, from: jsonData)
            switch resolvedData.type {
            case .notify:
                break
                
            case .newMess:
                try messingHandler(data: resolvedData.meaningData, of: req, using: decoder)
                break
                
            case .newBox: // new box
                break
                
            case .userTyping: // typing
                break
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        // old design.
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
        
//        do {
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .secondsSince1970
////
////            let dateFormatter = DateFormatter()
////            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
////            decoder.dateDecodingStrategy = .formatted(dateFormatter)
//            let mess = try decoder.decode(CreateMessage.self, from: jsonData)
//
//
//            // Save mess.
//            let createMessageInBox = Message(
//                creationDate: mess.creationDate,
//                text: mess.text,
//                boxId: mess.boxId,
//                fileId: mess.fileId,
//                type: mess.type,
//                sender_id: mess.sender_id,
//                senderIdOnRDBMS: mess.senderIdOnRDBMS
//            )
//            CoreEngine.mess(
//                createMessageInBox,
//                inDatabase: req.mongoDB
//            )
//
////            CoreEngine.findBox(
////                id: mess.boxId,
////                inDatabase: req.mongoDB
////            ).map { box in
//                webSocketPerUserManager.notifyMess(to: mess.members, content: createMessageInBox)
////            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
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
        webSocketPerUserManager.dictionary.removeValue(forKey: userId)
        webSocketPerUserManager.log()
    }
}



// MARK: - Handlers.
func messingHandler(data: String, of req: Request, using decoder: JSONDecoder) throws {
        // Save mess.
        let mess = try decoder.decode(CreateMessage.self, from: data.data(using: .utf8)!)
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
        webSocketPerUserManager.notifyMess(to: mess.members, content: createMessageInBox)
}









// MARK: - Structure.
struct ResolvedWSData: Codable, Content {
    let type: ResolvedWSDataType
    let meaningData: String
}

enum ResolvedWSDataType: Int, Content {
    case notify, newMess, newBox, userTyping
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
