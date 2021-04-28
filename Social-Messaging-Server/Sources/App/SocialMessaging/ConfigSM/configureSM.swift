//
//  configureSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor
import Leaf
import MongoKitten

// configures your application
public func configureSM(_ app: Application) throws {
    
    // Use leaf view rendering
    // Views are stored in Resources/Views as .leaf files
    app.views.use(.leaf)
    
    guard let connectionString = Environment.get("MONGODB") else {
        fatalError("No MongoDB connection string is available in .env")
    }
    // connectionString should be MONGODB=mongodb://localhost:27017,localhost:27018,localhost:27019/server
    try app.initializeMongoDBSM(connectionString: connectionString)
    
    // MARK: - Config http server.
    app.http.server.configuration.hostname = "172.20.10.5"
    app.http.server.configuration.port = 8080
    
    // Refer: /Users/vudat81299/Desktop/DiplomaProject/Server/Sources/App/routes.swift
    try routesSM(app) // Uncomment to run this service.
    
    try createTestingUsersSM(inDatabase: app.mongoDBSM)
    
    
    
}
