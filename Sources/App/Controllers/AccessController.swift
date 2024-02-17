//
//  File.swift
//
//
//  Created by Marcus Gugacs on 17.02.24.
//

import Fluent
import Vapor

struct AccessController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("register", use: register)
        
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: me);
    }

    func register(req: Request) async throws -> User {
        try User.Create.validate(content: req)
        
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        
        try await user.save(on: req.db)
        
        return user
    }

    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        
        try await token.save(on: req.db)
        
        return token
    }

    func me(req: Request) async throws -> User {
        try req.auth.require(User.self)
    }
}
