import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    //MARK: Получение всех упражнений
    app.get("exercises") { req -> EventLoopFuture<[Exercise]> in
        // Логирование начала обработки запроса
        req.logger.info("Received GET request for all exercises")
        
        // Запрос к базе данных
        return Exercise.query(on: req.db).all()
            .map { exercises in
                req.logger.info("Successfully fetched \(exercises.count) exercises")
                return exercises
            }
            .flatMapError { error in
                req.logger.error("Failed to fetch exercises: \(error.localizedDescription)")
                return req.eventLoop.future(error: Abort(.internalServerError, reason: "Failed to fetch exercises"))
            }
    }
    
    //MARK: Получение упражнения по ID всех упражнений
    app.get("exercises", ":id") { req -> EventLoopFuture<Exercise> in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            req.logger.error("Invalid ID format")
            throw Abort(.badRequest, reason: "Invalid ID format")
        }
        req.logger.info("Fetching exercise with ID \(id)")
        return Exercise.find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Exercise with this ID not found"))
    }
    
    //MARK: тестовый запрос
    app.get("test-exercises") { req -> EventLoopFuture<[String]> in
        Exercise.query(on: req.db).all().map { exercises in
            exercises.map { $0.name }
        }
    }

    try app.register(collection: TodoController())
}
