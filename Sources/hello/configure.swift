import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(configuration: .init(hostname: "localhost", username: "MD-heryhamzah", database: "learn_vapor", tls: .disable)), as: .psql)
    
    //register migration
    app.migrations.add(MyMigration())

    // register routes
    try routes(app)
}
