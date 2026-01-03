//
//  Login.swift
//  hello
//
//  Created by MD-HeryHamzah on 31/12/25.
//


import Vapor

struct RegisterRequest: Content {
    var name: String
    var email: String
    var password: String
    var confirmPassword: String
}
