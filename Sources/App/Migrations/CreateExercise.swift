//
//  CreateExercise.swift
//  FitnessAppServer
//
//  Created by Дима on 22.11.2024.
//


import Fluent

struct CreateExercise: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("exercises") // Имя таблицы
            .id() // Уникальный идентификатор (UUID)
            .field("name", .string, .required) // Поле "name" - строка, обязательное
            .field("description", .string, .required) // Поле "description" - строка, обязательное
            .field("image_url", .string, .required) // Поле "image_url" - строка, обязательное
            .create() // Создание таблицы
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("exercises").delete() // Удаление таблицы
    }
}