import FluentSQLite
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
    let sqlite = try SQLiteDatabase(storage: .file(path: "db.sqlite"))
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Quest.self, database: .sqlite)
    migrations.add(migration: AdminUser.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Media.self, database: .sqlite)
    
    
     migrations.add(model: Question.self, database: .sqlite)
     migrations.add(model: Answer.self, database: .sqlite)
     migrations.add(model: QuestQuestionInfo.self, database: .sqlite)
     migrations.add(model: InfoAnswerQuestion.self, database: .sqlite)
     migrations.add(model: ParticipationQuest.self, database: .sqlite)

     services.register(migrations)
}
