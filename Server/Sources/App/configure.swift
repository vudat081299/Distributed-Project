import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import FluentMongoDriver
//import LeafMarkdown

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    // Serves files from `Public/` directory
//    let fileMiddleware = FileMiddleware(
//        publicDirectory: app.directory.publicDirectory
//    )
//    app.middleware.use(fileMiddleware)
    
    // MARK: - Config http server.
//    app.http.server.configuration.hostname = "localhost"
//    app.http.server.configuration.port = 8081
    
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
    
    //
//    try app.databases.use(.mongo(connectionString: "<connection string>"), as: .mongo)

    // MARK: - Table of DB.
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAdminUser())
    
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
    try routes(app)
}
