import Foundation
import GRDB

class DatabaseManager {
    static let shared = DatabaseManager()

    private var dbQueue: DatabaseQueue!
    private let databaseFileName = "yomikae.sqlite"

    private init() {
        setupDatabase()
    }

    // MARK: - Database Setup

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let databaseURL = documentsDirectory.appendingPathComponent(databaseFileName)

            dbQueue = try DatabaseQueue(path: databaseURL.path)

            try createSchema()
            try loadInitialDataIfNeeded()
        } catch {
            fatalError("Database setup failed: \(error)")
        }
    }

    private func createSchema() throws {
        try dbQueue.write { db in
            // Create database metadata table for version tracking
            try db.create(table: "database_metadata", ifNotExists: true) { t in
                t.column("key", .text).primaryKey()
                t.column("value", .text).notNull()
            }

            // Create characters table
            try db.create(table: "characters", ifNotExists: true) { t in
                t.column("character", .text).primaryKey()
                t.column("japanese_json", .text)
                t.column("chinese_json", .text)
                t.column("stroke_count", .integer)
                t.column("radical", .text)
                t.column("frequency_rank", .integer)
                t.column("false_friend_id", .text)
            }

            // Create false_friends table
            try db.create(table: "false_friends", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("character", .text).notNull()
                t.column("jp_meanings_json", .text).notNull()
                t.column("cn_meanings_simplified_json", .text).notNull()
                t.column("cn_meanings_traditional_json", .text).notNull()
                t.column("severity", .text).notNull()
                t.column("category", .text).notNull()
                t.column("affected_system", .text).notNull()
                t.column("explanation", .text).notNull()
                t.column("examples_json", .text).notNull()
                t.column("traditional_note", .text)
                t.column("merged_from_json", .text)
            }

            // Create indexes
            try db.create(index: "idx_characters_frequency_rank",
                         on: "characters",
                         columns: ["frequency_rank"],
                         ifNotExists: true)

            try db.create(index: "idx_false_friends_severity",
                         on: "false_friends",
                         columns: ["severity"],
                         ifNotExists: true)

            try db.create(index: "idx_false_friends_character",
                         on: "false_friends",
                         columns: ["character"],
                         ifNotExists: true)

            // Set initial schema version
            try runMigrations(in: db)
        }
    }

    // MARK: - Database Migrations

    private let currentSchemaVersion = 1

    private func runMigrations(in db: Database) throws {
        let currentVersion = try getDatabaseVersion(in: db)

        guard currentVersion < currentSchemaVersion else {
            print("✅ Database schema is up to date (version \(currentVersion))")
            return
        }

        print("🔄 Running database migrations from version \(currentVersion) to \(currentSchemaVersion)...")

        // Run migrations sequentially
        for version in (currentVersion + 1)...currentSchemaVersion {
            try runMigration(toVersion: version, in: db)
        }

        // Update version
        try setDatabaseVersion(currentSchemaVersion, in: db)
        print("✅ Database migrated to version \(currentSchemaVersion)")
    }

    private func getDatabaseVersion(in db: Database) throws -> Int {
        if let versionString = try String.fetchOne(
            db,
            sql: "SELECT value FROM database_metadata WHERE key = 'schema_version'"
        ) {
            return Int(versionString) ?? 0
        }
        return 0
    }

    private func setDatabaseVersion(_ version: Int, in db: Database) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO database_metadata (key, value) VALUES ('schema_version', ?)",
            arguments: [String(version)]
        )
    }

    private func runMigration(toVersion version: Int, in db: Database) throws {
        print("  ⬆️ Migrating to version \(version)...")

        switch version {
        case 1:
            // Version 1 is the initial schema - no migration needed
            break

        // Future migrations go here
        // case 2:
        //     try db.create(table: "new_table") { t in
        //         ...
        //     }

        default:
            print("  ⚠️ Unknown migration version: \(version)")
        }
    }

    private func loadInitialDataIfNeeded() throws {
        let hasData = try dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM characters") ?? 0 > 0
        }

        guard !hasData else { return }

        try loadCharactersFromJSON()
        try loadFalseFriendsFromJSON()
    }

    // MARK: - Data Loading

    private func loadCharactersFromJSON() throws {
        do {
            print("📥 Importing characters from JSON...")
            let characters = try JSONImportService.importCharacters(from: "characters")

            try dbQueue.write { db in
                for character in characters {
                    try insertCharacter(character, in: db)
                }
            }

            print("✅ Successfully loaded \(characters.count) characters into database")
        } catch JSONImportError.fileNotFound(let filename) {
            print("⚠️ Warning: \(filename) not found in bundle - skipping character import")
        } catch JSONImportError.decodingError(let error) {
            print("❌ Error decoding characters JSON: \(error)")
            throw error
        } catch {
            print("❌ Error loading characters: \(error)")
            throw error
        }
    }

    private func loadFalseFriendsFromJSON() throws {
        do {
            print("📥 Importing false friends from JSON...")
            // Use v2 format by default
            let falseFriends = try JSONImportService.importFalseFriends(from: "false_friends_v2")

            try dbQueue.write { db in
                for falseFriend in falseFriends {
                    try insertFalseFriend(falseFriend, in: db)
                }
            }

            print("✅ Successfully loaded \(falseFriends.count) false friends into database")
        } catch JSONImportError.fileNotFound(let filename) {
            print("⚠️ Warning: \(filename) not found in bundle - skipping false friends import")
        } catch JSONImportError.decodingError(let error) {
            print("❌ Error decoding false friends JSON: \(error)")
            throw error
        } catch {
            print("❌ Error loading false friends: \(error)")
            throw error
        }
    }

    private func insertCharacter(_ character: Character, in db: Database) throws {
        let japaneseJSON = try character.japanese.map { try encodeToJSON($0) }
        let chineseJSON = try character.chinese.map { try encodeToJSON($0) }

        try db.execute(
            sql: """
                INSERT OR REPLACE INTO characters
                (character, japanese_json, chinese_json, stroke_count, radical, frequency_rank, false_friend_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [
                character.character,
                japaneseJSON,
                chineseJSON,
                character.strokeCount,
                character.radical,
                character.frequencyRank,
                character.falseFriendId
            ]
        )
    }

    private func insertFalseFriend(_ falseFriend: FalseFriend, in db: Database) throws {
        let jpMeaningsJSON = try encodeToJSON(falseFriend.jpMeanings)
        let cnMeaningsSimplifiedJSON = try encodeToJSON(falseFriend.cnMeaningsSimplified)
        let cnMeaningsTraditionalJSON = try encodeToJSON(falseFriend.cnMeaningsTraditional)
        let examplesJSON = try encodeToJSON(falseFriend.examples)
        let mergedFromJSON = try falseFriend.mergedFrom.map { try encodeToJSON($0) }

        try db.execute(
            sql: """
                INSERT OR REPLACE INTO false_friends
                (id, character, jp_meanings_json, cn_meanings_simplified_json, cn_meanings_traditional_json,
                 severity, category, affected_system, explanation, examples_json, traditional_note, merged_from_json)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [
                falseFriend.id,
                falseFriend.character,
                jpMeaningsJSON,
                cnMeaningsSimplifiedJSON,
                cnMeaningsTraditionalJSON,
                falseFriend.severity.rawValue,
                falseFriend.category.rawValue,
                falseFriend.affectedSystem.rawValue,
                falseFriend.explanation,
                examplesJSON,
                falseFriend.traditionalNote,
                mergedFromJSON
            ]
        )
    }

    // MARK: - Query Methods

    func searchCharacters(query: String, limit: Int = 100) -> [Character] {
        do {
            return try dbQueue.read { db in
                let sql = """
                    SELECT * FROM characters
                    WHERE character LIKE ? OR radical LIKE ?
                    ORDER BY frequency_rank ASC NULLS LAST
                    LIMIT ?
                    """
                let pattern = "%\(query)%"
                let rows = try Row.fetchAll(db, sql: sql, arguments: [pattern, pattern, limit])
                return try rows.map { try parseCharacter(from: $0) }
            }
        } catch {
            print("Error searching characters: \(error)")
            return []
        }
    }

    func getTopCharacters(limit: Int) -> [Character] {
        do {
            return try dbQueue.read { db in
                let sql = """
                    SELECT * FROM characters
                    WHERE frequency_rank IS NOT NULL
                    ORDER BY frequency_rank ASC
                    LIMIT ?
                    """
                let rows = try Row.fetchAll(db, sql: sql, arguments: [limit])
                return try rows.map { try parseCharacter(from: $0) }
            }
        } catch {
            print("Error fetching top characters: \(error)")
            return []
        }
    }

    func getFalseFriendCharacters() -> [Character] {
        do {
            return try dbQueue.read { db in
                let sql = """
                    SELECT * FROM characters
                    WHERE false_friend_id IS NOT NULL
                    ORDER BY frequency_rank ASC NULLS LAST
                    """
                let rows = try Row.fetchAll(db, sql: sql)
                return try rows.map { try parseCharacter(from: $0) }
            }
        } catch {
            print("Error fetching false friend characters: \(error)")
            return []
        }
    }

    func getCharactersByJLPTLevel(_ level: Int) -> [Character] {
        do {
            return try dbQueue.read { db in
                // Need to parse JSON to check JLPT level, so we'll filter in memory
                let sql = "SELECT * FROM characters WHERE japanese_json IS NOT NULL"
                let rows = try Row.fetchAll(db, sql: sql)
                let allCharacters = try rows.map { try parseCharacter(from: $0) }
                return allCharacters.filter { character in
                    character.japanese?.jlptLevel == level
                }
            }
        } catch {
            print("Error fetching characters by JLPT level: \(error)")
            return []
        }
    }

    func getCharacter(char: String) -> Character? {
        do {
            return try dbQueue.read { db in
                guard let row = try Row.fetchOne(
                    db,
                    sql: "SELECT * FROM characters WHERE character = ?",
                    arguments: [char]
                ) else {
                    return nil
                }
                return try parseCharacter(from: row)
            }
        } catch {
            print("Error fetching character: \(error)")
            return nil
        }
    }

    func getFalseFriend(id: String) -> FalseFriend? {
        do {
            return try dbQueue.read { db in
                guard let row = try Row.fetchOne(
                    db,
                    sql: "SELECT * FROM false_friends WHERE id = ?",
                    arguments: [id]
                ) else {
                    return nil
                }
                return try parseFalseFriend(from: row)
            }
        } catch {
            print("Error fetching false friend: \(error)")
            return nil
        }
    }

    func getAllFalseFriends(severity: Severity? = nil) -> [FalseFriend] {
        do {
            return try dbQueue.read { db in
                let sql: String
                let arguments: StatementArguments

                if let severity = severity {
                    sql = "SELECT * FROM false_friends WHERE severity = ? ORDER BY character"
                    arguments = [severity.rawValue]
                } else {
                    sql = "SELECT * FROM false_friends ORDER BY character"
                    arguments = []
                }

                let rows = try Row.fetchAll(db, sql: sql, arguments: arguments)
                return try rows.map { try parseFalseFriend(from: $0) }
            }
        } catch {
            print("Error fetching false friends: \(error)")
            return []
        }
    }

    func getFalseFriendForCharacter(_ char: String) -> FalseFriend? {
        do {
            return try dbQueue.read { db in
                guard let row = try Row.fetchOne(
                    db,
                    sql: "SELECT * FROM false_friends WHERE character = ?",
                    arguments: [char]
                ) else {
                    return nil
                }
                return try parseFalseFriend(from: row)
            }
        } catch {
            print("Error fetching false friend for character: \(error)")
            return nil
        }
    }

    // MARK: - Helper Methods

    private func encodeToJSON<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "DatabaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }
        return json
    }

    private func decodeFromJSON<T: Decodable>(_ json: String?, as type: T.Type) throws -> T? {
        guard let json = json, let data = json.data(using: .utf8) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }

    private func parseCharacter(from row: Row) throws -> Character {
        let japaneseJSON: String? = row["japanese_json"]
        let chineseJSON: String? = row["chinese_json"]

        let japanese = try decodeFromJSON(japaneseJSON, as: JapaneseReading.self)
        let chinese = try decodeFromJSON(chineseJSON, as: ChineseReading.self)

        return Character(
            character: row["character"],
            japanese: japanese,
            chinese: chinese,
            strokeCount: row["stroke_count"],
            radical: row["radical"],
            frequencyRank: row["frequency_rank"],
            falseFriendId: row["false_friend_id"]
        )
    }

    private func parseFalseFriend(from row: Row) throws -> FalseFriend {
        let jpMeaningsJSON: String = row["jp_meanings_json"]
        let cnMeaningsSimplifiedJSON: String = row["cn_meanings_simplified_json"]
        let cnMeaningsTraditionalJSON: String = row["cn_meanings_traditional_json"]
        let examplesJSON: String = row["examples_json"]
        let mergedFromJSON: String? = row["merged_from_json"]

        let jpMeanings = try decodeFromJSON(jpMeaningsJSON, as: [String].self) ?? []
        let cnMeaningsSimplified = try decodeFromJSON(cnMeaningsSimplifiedJSON, as: [String].self) ?? []
        let cnMeaningsTraditional = try decodeFromJSON(cnMeaningsTraditionalJSON, as: [String].self) ?? []
        let examples = try decodeFromJSON(examplesJSON, as: [Example].self) ?? []
        let mergedFrom = try decodeFromJSON(mergedFromJSON, as: [String].self)

        let severityString: String = row["severity"]
        let categoryString: String = row["category"]
        let affectedSystemString: String = row["affected_system"]

        guard let severity = Severity(rawValue: severityString),
              let category = Category(rawValue: categoryString),
              let affectedSystem = AffectedSystem(rawValue: affectedSystemString) else {
            throw NSError(domain: "DatabaseManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid enum values"])
        }

        return FalseFriend(
            id: row["id"],
            character: row["character"],
            jpMeanings: jpMeanings,
            cnMeaningsSimplified: cnMeaningsSimplified,
            cnMeaningsTraditional: cnMeaningsTraditional,
            severity: severity,
            category: category,
            affectedSystem: affectedSystem,
            explanation: row["explanation"],
            examples: examples,
            traditionalNote: row["traditional_note"],
            mergedFrom: mergedFrom
        )
    }
}
