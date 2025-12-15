//
//  Book.swift
//  hello
//
//  Created by MD-HeryHamzah on 07/11/25.
//

import Vapor
import FluentKit

enum BookType: String, Content, CaseIterable {
    case programming
    case mobile
    case backend
    case computer
    case architecture
    case uiux
    case advanced
    case functional
    case clean
    case concurrency
}

struct Book: Content {
    var name: String
    var price: Int
    var type: BookType
    var year: Int
}

// Struct sementara untuk parsing JSON mentah sebelum validasi enum
struct BookInput: Content {
    var name: String
    var price: Int
    var type: String
    var year: Int
}

struct BookUpdate: Content {
    var name: String?
    var price: Int?
    var type: String?
    var year: Int?
}

struct BookQuery: Content {
    var name: String?
    var type: String?
    var year: Int?
}

final class BookDb: Model, Content, @unchecked Sendable {
    
    static let schema: String = "books"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "price")
    var price: Int
    
    @Enum(key: "type")
    var type: BookType
    
    @Field(key: "year")
    var year: Int
    
    init() {
        
    }
    
    init(id: UUID? = nil, name: String, price: Int, type: BookType, year: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.type = type
        self.year = year
    }
}
