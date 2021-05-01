//import Vapor
//import Crypto
//
//var userIDListener = [String]()
//
//public func sockets(_ websockets: NIOWebSocketServer) {
//    
//    websockets.get("echo-test") { ws, req in
//        print("ws connnected")
//        ws.onText { ws, text in
//            print("ws received: \(text)")
//            ws.send("echo - \(text)")
//        }
//    }
//    
//    websockets.get("listen", TrackingSession.parameter) { ws, req in
//        let session = try req.parameters.next(TrackingSession.self)
//        guard sessionManager.sessions[session] != nil else {
//            ws.close()
//            return
//        }
//        
//        print(session)
//        
//        sessionManager.add(listener: ws, to: session)
//        
//        ws.onText { ws, text in
//            let string = text
//            let data = string.data(using: .utf8)!
//            var a = MessageForm(time: "", content: "", roomID: 0, from: "", to: "")
//            
//            if let json = try? JSONDecoder().decode(MessageForm.self, from: data){
//                a = json
//                let message = Message(time: a.time, content: a.content, roomID: a.roomID, from: a.from, to: a.to)
//                let _ = message.save(on: req)
//                print(a)
//            }
////            do {
////                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
////                {
////                    print("good json")
////                    print(jsonArray) // use the json here
////                } else {
////                    print("bad json")
////                }
////            } catch let error as NSError {
////                print(error)
////            }
//            sessionManager.update(text, for: session, to: a.to)
//        }
//    }
//}
