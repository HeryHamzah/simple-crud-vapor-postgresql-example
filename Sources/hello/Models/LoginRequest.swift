//
//  Login.swift
//  hello
//
//  Created by MD-HeryHamzah on 31/12/25.
//


import Vapor

struct LoginRequest: Content {
    var email: String
    var password: String
}
