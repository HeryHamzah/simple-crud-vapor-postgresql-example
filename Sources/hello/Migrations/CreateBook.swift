//
//  MyMigration.swift
//  hello
//
//  Created by MD-HeryHamzah on 14/12/25.
//

import Fluent

struct CreateBook: AsyncMigration {
    func revert(on database: any FluentKit.Database) async throws {
       try await database.schema("books")
            .delete()
    }
    
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("books")
            .id()
            .field("name", .string, .required)
            .field("price", .int, .required)
            .field("type", .string, .required)
            .field("year", .int, .required)
            .create()
    }
}
