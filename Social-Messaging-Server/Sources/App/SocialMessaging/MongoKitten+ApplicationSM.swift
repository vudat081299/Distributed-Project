////
////  MongoKitten+Application.swift
////
////
////  Created by Vũ Quý Đạt  on 25/04/2021.
////
//
//
//import Vapor
//import MongoKitten
//
//// 1
//private struct MongoDBStorageKeySM: StorageKey {
//    typealias Value = MongoDatabase
//}
//
//extension Application {
//    // 2
//    public var mongoDBSM: MongoDatabase {
//        get {
//            // Not having MongoDB would be a serious programming error
//            // Without MongoDB, the application does not function
//            // Therefore force unwrapping is used
//            return storage[MongoDBStorageKeySM.self]!
//        }
//        set {
//            storage[MongoDBStorageKeySM.self] = newValue
//        }
//    }
//
//    // 3
//    public func initializeMongoDBSM(connectionString: String) throws {
//        self.mongoDBSM = try MongoDatabase.connect(connectionString, on: self.eventLoopGroup).wait()
//    }
//}
//
//extension Request {
//    // 4
//    public var mongoDBSM: MongoDatabase {
//        // 5
//        return application.mongoDBSM.hopped(to: eventLoop)
//    }
//}
//
