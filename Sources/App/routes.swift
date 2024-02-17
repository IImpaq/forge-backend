import Fluent
import Vapor

func routes(_ app: Application) throws {
    // User management functionality
    try app.register(collection: AccessController())
    
    // User usability functionality
    try app.register(collection: UserController())
}
