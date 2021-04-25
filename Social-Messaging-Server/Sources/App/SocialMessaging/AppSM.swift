//
//  AppSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor
import Leaf
import MongoKitten



// MARK: - App.
public func makeSocialMessApp() throws -> Application {
    let app = Application()

    // Use leaf view rendering
    // Views are stored in Resources/Views as .leaf files
    app.views.use(.leaf)
    
    guard let connectionString = Environment.get("MONGODB") else {
        fatalError("No MongoDB connection string is available in .env")
    }
    // connectionString should be MONGODB=mongodb://localhost:27017,localhost:27018,localhost:27019/server
    try app.initializeMongoDBSM(connectionString: connectionString)
    
    // Refer: /Users/vudat81299/Desktop/DiplomaProject/Server/Sources/App/routes.swift
    routeOfSocialMess(to: app) // Uncomment to run this service.
    
    try createTestingUsersSM(inDatabase: app.mongoDBSM)
    
    return app
}



// MARK: - Context.




// MARK: - Route.
func routeOfSocialMess(to app: Application) {
    
    
}
