//
//  BooksController.swift
//  hello
//
//  Created by MD-HeryHamzah on 09/11/25.
//

import Vapor
import Fluent

//actor BooksStore {
//    private var books: [Book]
//    
//    init(initial: [Book] = []) {
//        self.books = initial
//    }
//    
//    func all() -> [Book] {
//        books
//    }
//    
//    
//    func filtered(type: BookType? = nil, year: Int? = nil, name: String? = nil) -> [Book] {
//        books.filter { book in
//            var isMatch : Bool = true
//            
//            if let name {
//                isMatch =  isMatch && book.name.localizedCaseInsensitiveContains(name)
//            }
//            
//            if let type {
//                isMatch = isMatch && book.type == type
//            }
//            
//            if let year {
//                isMatch = isMatch && book.year == year
//            }
//            
//            return isMatch
//        }
//    }
//    
//    func add(_ book: Book) {
//        books.append(book)
//    }
//}


struct BooksController: RouteCollection {
    
//    let store = BooksStore(initial: [
//        Book(name: "Swift Fundamentals", price: 150000, type: .programming, year: 2020),
//        Book(name: "Mastering iOS Development", price: 220000, type: .mobile, year: 2022),
//        Book(name: "Server-Side Swift with Vapor", price: 180000, type: .backend, year: 2021),
//        Book(name: "Data Structures in Swift", price: 165000, type: .computer, year: 2019),
//        Book(name: "Design Patterns for Swift", price: 195000, type: .architecture, year: 2020),
//        Book(name: "SwiftUI for Beginners", price: 140000, type: .uiux, year: 2021),
//        Book(name: "Advanced Swift", price: 250000, type: .advanced, year: 2023),
//        Book(name: "Functional Programming in Swift", price: 210000, type: .functional, year: 2022),
//        Book(name: "Clean Code in Swift", price: 200000, type: .clean, year: 2018),
//        Book(name: "Swift Concurrency Essentials", price: 175000, type: .concurrency, year: 2022),
//        Book(name: "iPadOS App Design with SwiftUI", price: 185000, type: .uiux, year: 2023),
//        Book(name: "Modern Backend APIs with Vapor", price: 230000, type: .backend, year: 2024),
//        Book(name: "Algorithms in Swift", price: 190000, type: .computer, year: 2020),
//        Book(name: "Clean Architecture in Swift", price: 245000, type: .architecture, year: 2021),
//        Book(name: "Effective Swift Testing", price: 160000, type: .programming, year: 2024),
//        Book(name: "SwiftUI Advanced Layouts", price: 205000, type: .uiux, year: 2024),
//        Book(name: "Async/Await in Depth", price: 215000, type: .concurrency, year: 2023),
//        Book(name: "Practical Functional Swift", price: 225000, type: .functional, year: 2021),
//        Book(name: "Clean Refactoring in Swift", price: 195000, type: .clean, year: 2022),
//        Book(name: "Mobile Networking in Swift", price: 175000, type: .mobile, year: 2020)
//    ])
    
    func boot(routes: any RoutesBuilder) throws {
        // Group utama tanpa middleware
        let books = routes.grouped("books")
        
        // Endpoint publik (tanpa auth)
//        books.get(use: show)
//        books.get(":type", use: showByType)
//        books.get(":type", ":year", use: showByTypeAndYear)
        
        // Group terlindungi hanya untuk endpoint tertentu
        let protected = books.grouped(AuthenticationMiddleware())
        protected.get(use: show)
        protected.post(use: create)
        protected.get(":id", use: showById)
        protected.delete(":id", use: deleteBook)
        protected.put(":id", use: updateBook)

    }
    
    func showById(req: Request) async throws -> BookDb {
    
        guard let book =  try await BookDb.find(req.parameters.get("id"), on: req.db) else {
          throw  Abort(.badRequest)
        }
        
        return book
    }
    
    func deleteBook(req: Request) async throws -> BookDb  {
    
        guard let book =  try await BookDb.find(req.parameters.get("id"), on: req.db) else {
          throw  Abort(.badRequest)
        }
        
        try await book.delete(on: req.db)
        
        return book;
        
    }
    
    func updateBook(req: Request) async throws -> BookDb {

        // Decode DTO (bukan Model DB)
        let input = try req.content.decode(BookUpdate.self)

        // Cari book
        guard let book = try await BookDb.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound, reason: "Book not found")
        }

        // Update field hanya jika dikirim
        if let name = input.name {
            book.name = name
        }

        if let price = input.price {
            guard price > 0 else {
                throw Abort(.badRequest, reason: "Price must be greater than 0")
            }
            book.price = price
        }

        if let type = input.type {
            guard let bookType = BookType(rawValue: type.lowercased()) else {
                throw Abort(
                    .badRequest,
                    reason: "Invalid book type. Allowed values: \(BookType.allCases.map(\.rawValue).joined(separator: ", "))"
                )
            }
            book.type = bookType
        }

        if let year = input.year {
            guard year >= 2000 else {
                throw Abort(.badRequest, reason: "Year must be >= 2000")
            }
            book.year = year
        }

        // Simpan perubahan
        try await book.update(on: req.db)

        return book
    }

    
    // GET /books?name=...&type=...&year=...
    func show(req: Request) async throws -> [BookDb] {
        let queryBook = try req.query.decode(BookQuery.self)

        // Parse type string -> BookType
        var parsedType: BookType? = nil
        if let typeStr = queryBook.type {
            guard let t = BookType(rawValue: typeStr.lowercased()) else {
                throw Abort(.badRequest, reason: "Invalid 'type' parameter. Allowed values: \(BookType.allCases.map { $0.rawValue }.joined(separator: ", "))")
            }
            parsedType = t
        }

        // Build query with conditional filters
        var builder = BookDb.query(on: req.db)

        if let name = queryBook.name, !name.isEmpty {
            builder = builder.filter(\.$name, .custom("ilike"), "%\(name)%")
        }
        if let t = parsedType {
            builder = builder.filter(\.$type == t)
        }
        if let year = queryBook.year {
            builder = builder.filter(\.$year == year)
        }

        let data = try await builder.all()
        return data
    }
    
//    // books/:type
//    func showByType(req: Request) async throws -> [Book] {
//        guard let typeParam = req.parameters.get("type") else {
//            throw Abort(.badRequest, reason: "Missing 'type' parameter.")
//        }
//        let normalized = typeParam.lowercased()
//        guard let bookType = BookType(rawValue: normalized) else {
//            throw Abort(.badRequest, reason: "Invalid book type: \(typeParam)")
//        }
//        return await store.filtered(type: bookType)
//    }
//    
//    // books/:type/:year
//    func showByTypeAndYear(req: Request) async throws -> [Book] {
//        guard let typeParam = req.parameters.get("type") else {
//            throw Abort(.badRequest, reason: "Missing 'type' parameter.")
//        }
//        let normalized = typeParam.lowercased()
//        guard let bookType = BookType(rawValue: normalized) else {
//            throw Abort(.badRequest, reason: "Invalid book type: \(typeParam)")
//        }
//        
//        guard let yearString = req.parameters.get("year") else {
//            throw Abort(.badRequest, reason: "Missing 'year' parameter.")
//        }
//        
//        guard let year = Int(yearString) else {
//            throw Abort(.badRequest, reason: "Invalid 'year' parameter. Expected an integer.")
//        }
//        
//        return await store.filtered(type: bookType, year: year)
//    }
//
    
    func create(req: Request) async throws -> BookDb {
        do {
            let input = try req.content.decode(BookInput.self)
            
            guard let bookType = BookType(rawValue: input.type.lowercased()) else {
                throw Abort(.badRequest, reason: "Invalid book type: \(input.type). Allowed values: \(BookType.allCases.map { $0.rawValue }.joined(separator: ", "))")
            }
            
            guard input.price > 0 else {
                throw Abort(.badRequest, reason: "Price must be greater than 0.")
            }
            
            guard input.year >= 2000 else {
                throw Abort(.badRequest, reason: "Year must be >= 2000.")
            }
            
            let book = BookDb(
                name: input.name,
                price: input.price,
                type: bookType,
                year: input.year
            )
            
            try await book.save(on: req.db)
            
            return book
        } catch let error as DecodingError {
            throw Abort(.badRequest, reason: "Invalid request body: \(error.localizedDescription)")
        } catch {
            throw Abort(.internalServerError, reason: "Unexpected error: \(error.localizedDescription)")
        }
    }
}
