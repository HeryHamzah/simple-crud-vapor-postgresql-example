//
//  AuthenticationMidlleware.swift
//  hello
//
//  Created by MD-HeryHamzah on 12/11/25.
//

import Vapor

struct AuthenticationMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {

        _ = try await request.jwt.verify(as: UserPayload.self)
        return try await next.respond(to: request)
    }
    
    
}
