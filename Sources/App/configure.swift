import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // Создайте конфигурацию для PostgreSQL
    let postgresConfig = SQLPostgresConfiguration(
        hostname: "localhost",       // Адрес базы данных
        port: 5432,                  // Порт базы данных
        username: "postgres",        // Имя пользователя
        password: "password",        // Пароль пользователя
        database: "exercises",       // Имя базы данных
        tls: .disable //Конфигурация протокола шифрования данных - отключаем
    )

    // Настройка базы данных с использованием SQLPostgresConfiguration
    app.databases.use(.postgres(
        configuration: postgresConfig,
        maxConnectionsPerEventLoop: 10,            // Максимальное количество соединений на event loop
        connectionPoolTimeout: .seconds(10),       // Таймаут для пула соединений
        encodingContext: .default,                // Настройки кодирования
        decodingContext: .default,                // Настройки декодирования
        sqlLogLevel: .debug                       // Уровень логирования SQL-запросов
    ), as: .psql)

    // Добавьте миграции
    app.migrations.add(CreateExercise())

    // Автоматически применяйте миграции
    try app.autoMigrate().wait()
    
    // Регистрация маршрутов
    try routes(app)
}
