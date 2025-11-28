//
//  TestRecord.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import Foundation
import GRDB

struct TestRecord: Codable {
    var id: Int64?
    var message: String
    var createdAt: Date

    init(message: String) {
        self.message = message
        self.createdAt = Date()
    }
}

extension TestRecord: FetchableRecord, PersistableRecord {
    static let databaseTableName = "test_records"

    enum Columns {
        static let id = Column("id")
        static let message = Column("message")
        static let createdAt = Column("createdAt")
    }
}

extension TestRecord {
    static func createTable(in db: Database) throws {
        try db.create(table: databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("message", .text).notNull()
            table.column("createdAt", .datetime).notNull()
        }
    }
}
