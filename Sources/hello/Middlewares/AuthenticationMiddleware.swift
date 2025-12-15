//
//  AuthenticationMidlleware.swift
//  hello
//
//  Created by MD-HeryHamzah on 12/11/25.
//

import Vapor

struct AuthenticationMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {

        guard request.headers.bearerAuthorization != nil else {
            throw Abort(.unauthorized)
        }
        
        return try await next.respond(to: request)
    }
    
    
}
