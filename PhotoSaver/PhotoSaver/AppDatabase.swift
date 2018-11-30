import GRDB

/// Ref: AppDelegate.setupDatabase()
struct AppDatabase {
    //程序启动的时候调用Queue或者Pool的打开
    static func openDatabaseQueue(_ path: String) throws -> DatabaseQueue {
        // Ref: https://github.com/groue/GRDB.swift/#database-connections
        log.info("正在启动数据库（Queue）。")
        let dbConn = try DatabaseQueue(path: path)
        //log.info("正在清空数据库。")
        //try dbConn.erase()

        // Use DatabaseMigrator to define the database schema
        // See https://github.com/groue/GRDB.swift/#migrations
        log.info("即将执行数据库迁移。")
        
        try migrator.migrate(dbConn)

        return dbConn
    }

    static func openDatabasePool(_ path: String) throws -> DatabasePool {
        // Ref: https://github.com/groue/GRDB.swift/#database-connections
         log.info("正在启动数据库（Queue）。")
        let dbConn = try DatabasePool(path: path)
         log.info("正在清空数据库。")
        try dbConn.erase()

        // Use DatabaseMigrator to define the database schema
        // See https://github.com/groue/GRDB.swift/#migrations
        log.info("即将执行数据库迁移。")
        try migrator.migrate(dbConn)

        return dbConn
    }

    // Ref: https://github.com/groue/GRDB.swift/#migrations
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v0.1.create_tables") { db in
            log.info("即将执行数据库迁移v0.1.create_tables。")
            // Ref: https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "settingsModel") { t in
                t.column("settingsType", .integer).primaryKey()
                t.column("contents", .text)
            }
            try db.create(table: "albumModel") { t in
                //uuids as 16-bytes data blobs
                t.column("id", .text).primaryKey()
                t.column("collectionId", .text).notNull().unique()
                t.column("collectionType", .integer).notNull()
                t.column("collectionSubtype", .integer).notNull()
                // Ref: https://github.com/groue/GRDB.swift/#unicode
                t.column("title", .text).notNull().collate(.localizedCaseInsensitiveCompare)
            }
            try db.create(table: "imageModel") { t in
                t.column("id", .text).primaryKey()
                t.column("assetId", .text).notNull().unique()
                t.column("mediaType", .integer).notNull()
            }
            try db.create(table: "sectionModel") { t in
                t.column("albumId", .text)
                    .notNull()
                    .references("albumModel", onDelete: .cascade)
                t.column("title", .text)
                    .notNull()
                    .collate(.localizedCaseInsensitiveCompare)
                t.column("imageId", .text)
                    .notNull()
                    .references("imageModel", onDelete: .cascade)
                t.primaryKey(["albumId", "title", "imageId"])
            }
        }

        migrator.registerMigration("fixtures") { db in
//            log.info("即将执行数据库迁移v0.1.create_tables。")
//            // Populate the players table with random data
//            for _ in 0..<8 {
//                var player = Player(id: nil, name: Player.randomName(), score: Player.randomScore())
//                try player.insert(db)
//            }
        }

        return migrator
    }
}

