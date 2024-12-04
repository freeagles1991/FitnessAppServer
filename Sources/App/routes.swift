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
    
    //MARK: Добавление нового упражнения
    app.post("exercises") { req -> EventLoopFuture<Exercise> in
        // Декодируем данные из тела запроса в объект Exercise
        let exercise = try req.content.decode(Exercise.self)

        // Сохраняем объект в базе данных
        return exercise.save(on: req.db).map {
            req.logger.info("Exercise \(exercise.name) added successfully")
            return exercise
        }
        .flatMapError { error in
            req.logger.error("Failed to save exercise: \(error.localizedDescription)")
            return req.eventLoop.future(error: Abort(.internalServerError, reason: "Failed to save exercise"))
        }
    }
    
    //MARK: Маршрут для удаления записи по ID
    app.delete("exercises", ":id") { req -> EventLoopFuture<HTTPStatus> in
        // Получение ID из параметров маршрута
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid ID format")
        }

        // Поиск записи и её удаление
        return Exercise.find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Exercise with ID \(id) not found"))
            .flatMap { exercise in
                exercise.delete(on: req.db)
            }
            .transform(to: .ok)
    }
    
    //MARK: Маршрут для обновления записи по ID
    app.put("exercises", ":id") { req -> EventLoopFuture<Exercise> in
        // Получение ID из параметров маршрута
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid ID format")
        }

        // Декодирование данных из тела запроса
        let updatedExercise = try req.content.decode(Exercise.self)

        // Поиск записи, обновление её данных и сохранение
        return Exercise.find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Exercise with ID \(id) not found"))
            .flatMap { existingExercise in
                existingExercise.name = updatedExercise.name
                existingExercise.description = updatedExercise.description
                existingExercise.imageUrl = updatedExercise.imageUrl
                return existingExercise.save(on: req.db).map { existingExercise }
            }
    }
    
    
    //MARK: тестовый запрос
    app.get("test-exercises") { req -> EventLoopFuture<[String]> in
        Exercise.query(on: req.db).all().map { exercises in
            exercises.map { $0.name }
        }
    }

    try app.register(collection: TodoController())
}
