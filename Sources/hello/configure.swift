import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)


    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(configuration: .init(hostname: "localhost", username: "MD-heryhamzah", database: "learn_vapor", tls: .disable)), as: .psql)
    
    //register migration
    app.migrations.add(CreateBook())
    app.migrations.add(CreateUser())


    // register routes
    try routes(app)
}
