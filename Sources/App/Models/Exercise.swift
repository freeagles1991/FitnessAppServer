//
//  Exercise.swift
//  FitnessAppServer
//
//  Created by Дима on 22.11.2024.
//


import Fluent
import Vapor

final class Exercise: Model, Content, @unchecked Sendable {
    static let schema = "exercises" // Имя таблицы

    @ID(key: .id)
    var id: UUID? // Уникальный идентификатор

    @Field(key: "name")
    var name: String // Название упражнения

    @Field(key: "description")
    var description: String // Описание упражнения

    @Field(key: "image_url")
    var imageUrl: String // URL изображения упражнения

    init() {}

    init(id: UUID? = nil, name: String, description: String, imageUrl: String) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
    }
}
