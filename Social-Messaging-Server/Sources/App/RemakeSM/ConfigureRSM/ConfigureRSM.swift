//
//  ConfigureRSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import MongoKitten

// configures your application
public func configureRSM(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    // Serves files from `Public/` directory
//    let fileMiddleware = FileMiddleware(
//        publicDirectory: app.directory.publicDirectory
//    )
//    app.middleware.use(fileMiddleware)
    
    // MARK: - Config http server."
    app.http.server.configuration.hostname = "10.2.75.16"
    app.http.server.configuration.port = 8080
    app.routes.defaultMaxBodySize = "20mb"
    
    // MARK: - Config DB.
    let databaseName: String
    let databasePort: Int
    if (app.environment == .testing) {
      databaseName = "vapor-test"
      if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5433
      } else {
        databasePort = 5433
      }
    } else {
      databaseName = "vapor_database"
      databasePort = 5432
    }
    
    // default port for psql
    // port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)
    
    // MARK: - Connect MongoDB.
    guard let connectionString = Environment.get("MONGODB") else {
        fatalError("No MongoDB connection string is available in .env")
    }
    // connectionString should be MONGODB=mongodb://localhost:27017,localhost:27018,localhost:27019/social-messaging-server
    try app.initializeMongoDB(connectionString: connectionString)

    // MARK: - Table of DB.
    app.migrations.add(CreateUserRSM())
    app.migrations.add(CreateTokenRSM())
    
    app.logger.logLevel = .debug
    
    try app.autoMigrate().wait()

    app.views.use(.leaf)
//    app.leaf.tags["markdown"] = Markdown() //
    
    // MARK: - Change the encoders and decoders.
    // Global
    // create a new JSON encoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    // register routes
    try routesRSM(app)
//    try createTestingUserRSMNoSQL(inDatabase: app.mongoDB)
}

/*
func createTestingUserRSMNoSQL(inDatabase database: MongoDatabase) throws {
    let userCount = try database[UserRSMNoSQL.collection].count().wait()
    if userCount > 0 {
        // The testing users have already been created
        return
    }
    
    let ray = UserRSMNoSQL(
        _id: ObjectId(),
        idOnRDBMS: UUID(uuidString: "kljshval2h34klj2h")!,
        name: "vudat81299",
        username: "vudat81299",
        lastName: "vudat81299",
        bio: "vudat81299",
        privacy: .publicState,
        profilePicture: "vudat81299",
        personalData: PersonalData(
            phoneNumber: "vudat81299",
            email: "vudat81299",
            dob: "vudat81299",
            idDevice: "vudat81299",
            block: []),
        following: [],
        box: []
    )
    
    
    
    let mainUser = UserRSMNoSQL(
        _id: ObjectId(),
        idOnRDBMS: UUID(uuidString: "trangsdfaksdflas")!,
        name: "trang",
        username: "trang",
        lastName: "trang",
        bio: "trang",
        privacy: .publicState,
        profilePicture: "trang",
        personalData: PersonalData(
            phoneNumber: "trang",
            email: "trang",
            dob: "trang",
            idDevice: "trang",
            block: []),
        following: [],
        box: []
    )
    
    let createdAdmin = database[UserRSMNoSQL.collection].insertEncoded(mainUser)
    let createdUsers = database[UserRSMNoSQL.collection].insertManyEncoded([
        ray
    ])
    
    _ = try createdAdmin.and(createdUsers).wait()
}
*/
