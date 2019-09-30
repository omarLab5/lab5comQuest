//
//  User.swift
//  App
//
//  Created by MacBook Pro on 04/09/2019.
//

import Vapor
import FluentSQLite
import Authentication


final class User: Codable {
    var id: Int?
    var email : String
    var fullName : String
    var password: String
    var phoneNumber : String
    
    
    init(email: String, fullName: String , password : String , phoneNumber : String) {
        self.email = email
        self.fullName = fullName
        self.password = password
        self.phoneNumber = phoneNumber
    }
    
    
    final class Public: Codable {
        var id: Int?
        var email: String
        var fullName: String
        var phoneNumber : String

        init(id: Int?, email: String, fullName: String , phoneNumber : String) {
            self.id = id
            self.email = email
            self.fullName = fullName
            self.phoneNumber = phoneNumber

        }
    }
}

extension User: SQLiteModel {}

extension User: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.email)
        }
    }
}


extension User: Content {}
extension User: Parameter {}
extension User.Public: Content {}

extension User {
    func toPublic() -> User.Public {
        return User.Public(id: id, email: email , fullName: fullName , phoneNumber: phoneNumber)
    }
    
    var quests: Children<User, Quest> {
        return children(\.userID)
    }
    
 
    
    var participationUser: Children<User, ParticipationQuest> {
        return children(\.userID)
    }
    
}


extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}


extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey {
        return \User.fullName
    }
    
    static var passwordKey: PasswordKey {
        return \User.password
    }
}


struct AdminUser: Migration {
    typealias Database = SQLiteDatabase
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password") // NOT do this for production
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(email: "admin@admin.com", fullName: "admin", password: hashedPassword , phoneNumber: "admin")
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return .done(on: conn)
    }
}


extension User: TokenAuthenticatable {
    typealias TokenType = Token
}


extension User: Validatable {
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.email, .email)
        return validations
    }
}

