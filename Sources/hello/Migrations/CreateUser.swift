//
//  UserMigration.swift
//  hello
//
//  Created by MD-HeryHamzah on 02/01/26.
//

import Fluent

struct CreateUser: AsyncMigration {
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("users")
            .delete()
    }
    
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("users")
                    .id()
                    .field("name", .string, .required)
                    .field("email", .string, .required)
                    .field("password_hash", .string, .required)
                    .field("created_at", .datetime)
                    .unique(on: "email")
                    .create()
    }
}
