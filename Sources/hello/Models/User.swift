//
//  User.swift
//  hello
//
//  Created by MD-HeryHamzah on 02/01/26.
//

import Vapor
import Fluent

struct UserResponse: Content {
    var id: UUID
    var name: String
    var email: String
    var createdAt: Date?
}

final class UserDb: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        email: String,
        passwordHash: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}
