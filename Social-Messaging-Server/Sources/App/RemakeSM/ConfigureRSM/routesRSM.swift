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
        
        
        
        
        let a = """
{
   "type": 1,
    "majorData": {"boxId": "60a0c4a6d41b94d16d43b6d7", "creationDate": 1621150327.421111, "text": "Hello this is first mess!", "fileId": "6094d82ddba87b2eb8b413f3", "type": 1, "senderId": "609ea00683818e382c32bbd8", "senderIdOnRDBMS": "FECE0C19-60BE-4DFC-87BA-31749B9459F7", "members": ["D8D04A41-A7DD-4A4B-BBF1-EBD314900F0E", "FECE0C19-60BE-4DFC-87BA-31749B9459F7"]}
}
"""
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let resolvedData = try decoder.decode(WSResolvedDataTest.self, from: a.data(using: .utf8)!)
            print(resolvedData)
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
}

func webSocketBehaviorHandler(req: Request, socket: WebSocket, of userId: String) {
    socket.onText { _, text in
        let jsonData = text.data(using: .utf8)!
        print(jsonData)
        // sample to post in ws.
//        {
//           "type": 1,
//            "majorData": {"boxId": "60a0c4a6d41b94d16d43b6d7", "creationDate": 1621150327.421111, "text": "Hello this is first mess!", "fileId": "6094d82ddba87b2eb8b413f3", "type": 1, "senderId": "609ea00683818e382c32bbd8", "senderIdOnRDBMS": "FECE0C19-60BE-4DFC-87BA-31749B9459F7", "members": ["D8D04A41-A7DD-4A4B-BBF1-EBD314900F0E", "FECE0C19-60BE-4DFC-87BA-31749B9459F7"]}
//        }
        
        // new design.
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let resolvedData = try decoder.decode(WSResolvedData.self, from: jsonData)
            switch resolvedData.type {
            case .notify:
                break
                
            case .newMess:
                try messingHandler(data: resolvedData.majorData, of: req, using: decoder)
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
        switch result {
        case .success:
            webSocketPerUserManager.removeSession(of: userId)
            print("close ws successful!")
            break
            
        case .failure:
            print("close ws unsuccessful!")
            break
        }
    }
}



// MARK: - Handlers.
func messingHandler(data: WSResolvedMessage, of req: Request, using decoder: JSONDecoder) throws {
    // Save mess.
//    let mess = try decoder.decode(WSResolvedMessage.self, from: data.data(using: .utf8)!)
    let mess = data
    let createMessageInBox = Message(
        _id: ObjectId(),
        creationDate: mess.creationDate,
        text: mess.text,
        boxId: mess.boxId,
        fileId: mess.fileId,
        type: mess.type,
        senderId: mess.senderId,
        senderIdOnRDBMS: mess.senderIdOnRDBMS
    )
    
    // save into db
    CoreEngine.mess(
        createMessageInBox,
        inDatabase: req.mongoDB
    )
    
    // notify to all recipients of box.
//    do {
//        let encoder = JSONEncoder()
//    let context = WSEncodeContext(type: .newMess, majorData: try encoder.encode(createMessageInBox))
    let context = WSEncodeContext(type: .newMess, majorData: createMessageInBox)
        webSocketPerUserManager.notifyMess(to: mess.members, content: context)
//    } catch {
//        print(error.localizedDescription)
//    }
}









// MARK: - Structure.
struct WSResolvedData: Decodable {
    let type: WSResolvedMajorDataType
    let majorData: WSResolvedMessage
}

enum WSResolvedMajorDataType: Int, Codable {
    case notify, newMess, newBox, userTyping
}

struct WSResolvedMessage: Decodable {
    let boxId: ObjectId
    let creationDate: Date
    let text: String?
    let fileId: ObjectId?
    let type: MediaType
    let senderId: ObjectId
    let senderIdOnRDBMS: UUID
    
    let members: [UUID]
}

struct WSEncodeContext: Encodable {
    let type: WSResolvedMajorDataType
    let majorData: Message
}

struct WSResolvedDataTest: Decodable {
    let type: WSResolvedMajorDataType
    let majorData: WSResolvedMessage
}

struct WSResolvedMessageTest: Decodable {
    let boxId: ObjectId
    let creationDate: Date
    let text: String?
    let fileId: ObjectId?
    let type: MediaType
    let senderId: ObjectId
    let senderIdOnRDBMS: UUID

    let members: [UUID]
}
