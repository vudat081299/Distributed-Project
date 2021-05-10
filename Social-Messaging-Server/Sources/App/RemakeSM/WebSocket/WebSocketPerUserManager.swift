//
//  WebSocketPerUserManager.swift
//  
//
//  Created by Vũ Quý Đạt  on 07/05/2021.
//

import Vapor

let webSocketPerUserManager = WebSocketPerUserManager()
final class WebSocketPerUserManager {
    
    private(set) var sessions: LockedDictionary<String, WebSocket> = [:]
    var listWS: [WebSocket] = []
    // MARK: Observer Interactions
    
    var dictionary: [String: WebSocket] = [:]
    
    func add(ws: WebSocket, to userId: String) {
        dictionary[userId] = ws
//        listWS.append(ws)
        print(dictionary)
    }
    
    func log() {
        print(dictionary.count)
        print(dictionary)
    }
    
    func notifyMess(to userIds: [UUID], content: Message) {
        userIds.forEach { id in
            if let ws = dictionary[id.uuidString] {
                ws.send(content)
            }
        }
//        listWS.forEach { ws in
//            ws.send(content)
//        }
    }
    
//    func remove(listener: WebSocket, from session: TrackingSession) {
//        guard var listeners = sessions[session] else { return }
//        listeners = listeners.filter { $0 !== listener }
//        sessions[session] = listeners
//    }
    
    // MARK: Poster Interactions
    
//    func createTrackingSession(for request: Request) -> Future<TrackingSession> {
//        return wordKey(with: request)
//            .flatMap(to: TrackingSession.self) { [unowned self] key -> Future<TrackingSession> in
//                let session = TrackingSession(id: key)
//                guard self.sessions[session] == nil else {
//                    return self.createTrackingSession(for: request)
//                }
//                self.sessions[session] = []
//                return Future.map(on: request) { session }
//        }
//    }
    
//    func createTrackingSessionForIndivisualUser(for userID: String) -> HTTPStatus {
//        let session = TrackingSession(id: userID)
//        guard self.sessions[session] == nil else {
//            return .ok
//        }
//        self.sessions[session] = []
//        return .ok
//    }
//
//    func createTrackingSession(for form: CreatedSocketForm, roomID: Int, userID: String) -> ResponseCreateWS {
//        let id = form.from > form.to ? "\(form.from)\(form.to)" : "\(form.to)\(form.from)"
//        let session = TrackingSession(id: id)
//        print("WS: \(id)")
//        guard self.sessions[session] == nil else {
//            return ResponseCreateWS(code: 1010, message: "Session already exist!", data: InFoWS(id: id, roomID: roomID))
//        }
//        self.sessions[session] = []
//        return ResponseCreateWS(code: 1000, message: "Successful!", data: InFoWS(id: id, roomID: roomID))
//    }
//
//    func update(_ location: String, for session: TrackingSession, to userID: String = "") {
//        guard let listeners = sessions[session] else { return }
//        listeners.forEach { ws in ws.send(location) }
//
////        let notifySession = TrackingSession(id: userID)
////        guard let notifyListeners = sessions[notifySession] else { return }
////        notifyListeners.forEach { ws in ws.send(location) }
//    }
//
//    func notify(to userID: String = "", content: String) {
//        let notifySession = TrackingSession(id: userID)
//        guard let notifyListeners = sessions[notifySession] else { return }
//        notifyListeners.forEach { ws in ws.send(content) }
//    }
//
//    func close(_ session: TrackingSession) {
//        guard let listeners = sessions[session] else { return }
//        listeners.forEach { ws in
//            ws.close()
//        }
//        sessions[session] = nil
//    }
}
