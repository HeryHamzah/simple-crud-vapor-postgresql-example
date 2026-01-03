//
//  AuthController.swift
//  hello
//
//  Created by MD-HeryHamzah on 30/12/25.
//

import Vapor
import Fluent
import JWTKit

struct AuthController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("authentication")
        
        auth.post("login", use: login)
        auth.post("register", use: register)
        
        let protected = auth.grouped(AuthenticationMiddleware())
        
        protected.get("me", use: me)
        
    }
    
    // MARK: - Register
    func register(req: Request) async throws -> HTTPStatus {
        
        let data = try req.content.decode(RegisterRequest.self)
        
        guard data.password == data.confirmPassword else {
            throw Abort(.badRequest, reason: "Password confirmation does not match.")
        }
        
        let passwordHash = try Bcrypt.hash(data.password)
        
        let user = UserDb(name: data.name, email: data.email, passwordHash: passwordHash)
        
        try await user.save(on: req.db)
        
        return .created
    }
    
    // MARK: - Login
    func login(req: Request) async throws -> LoginResponse {
        
        let data = try req.content.decode(LoginRequest.self)
        
        guard let user = try await UserDb.query(on: req.db)
            .filter(\.$email == data.email)
            .first()
        else {
            throw Abort(.unauthorized)
        }
        
        guard try Bcrypt.verify(data.password, created: user.passwordHash) else {
            throw Abort(.unauthorized)
        }
        
        guard let userId = user.id else {
            throw Abort(.internalServerError)
        }
        
        let payload = UserPayload(
            subject: SubjectClaim(value: userId.uuidString),
            expiration:  .init(value: .distantFuture)
        )
        
        
        let token = try await req.jwt.sign(payload)
        
        return LoginResponse(token: token)
    }
    
    // MARK: - Me
    func me(req: Request) async throws -> UserResponse {
        
        let payload = try await req.jwt.verify(as: UserPayload.self)
        
        guard let userId = UUID(uuidString: payload.subject.value),
              let user = try await UserDb.find(userId, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        guard let userDbId = user.id else {
            throw Abort(.internalServerError)
        }
        
        return UserResponse(id: userDbId, name: user.name, email: user.email, createdAt: user.createdAt)
    }
    
    
}
