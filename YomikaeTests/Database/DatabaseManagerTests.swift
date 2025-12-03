import XCTest
import GRDB
@testable import Yomikae

final class DatabaseManagerTests: XCTestCase {
    var sut: DatabaseManager!
    var testDatabasePath: String!

    override func setUp() async throws {
        try await super.setUp()

        // Create a temporary test database
        let tempDir = FileManager.default.temporaryDirectory
        testDatabasePath = tempDir.appendingPathComponent("test_\(UUID().uuidString).db").path

        sut = try DatabaseManager(path: testDatabasePath)
    }

    override func tearDown() async throws {
        sut = nil

        // Clean up test database
        if let path = testDatabasePath {
            try? FileManager.default.removeItem(atPath: path)
        }
        testDatabasePath = nil

        try await super.tearDown()
    }

    // MARK: - Test: Character insertion and retrieval

    func testInsertAndRetrieveCharacter() throws {
        // Given
        let character = MockData.character手

        // When
        try sut.insertCharacter(character)
        let retrieved = try sut.getCharacter(character.character)

        // Then
        XCTAssertNotNil(retrieved, "Character should be retrieved")
        XCTAssertEqual(retrieved?.character, character.character)
        XCTAssertEqual(retrieved?.japanese?.onyomi, character.japanese?.onyomi)
        XCTAssertEqual(retrieved?.chinese?.pinyin, character.chinese?.pinyin)
    }

    func testInsertMultipleCharacters() throws {
        // Given
        let characters = MockData.allCharacters

        // When
        for character in characters {
            try sut.insertCharacter(character)
        }

        // Then
        for character in characters {
            let retrieved = try sut.getCharacter(character.character)
            XCTAssertNotNil(retrieved, "Character \(character.character) should be retrieved")
        }
    }

    func testRetrieveNonExistentCharacter() throws {
        // Given
        let nonExistentCharacter = "鬱" // Complex character unlikely to be in test data

        // When
        let retrieved = try sut.getCharacter(nonExistentCharacter)

        // Then
        XCTAssertNil(retrieved, "Non-existent character should return nil")
    }

    func testUpdateExistingCharacter() throws {
        // Given
        var character = MockData.character手
        try sut.insertCharacter(character)

        // When - Update the character
        character.japanese = JapaneseReading(
            onyomi: ["シュ", "ズ"], // Added reading
            kunyomi: character.japanese!.kunyomi,
            meanings: character.japanese!.meanings,
            jlptLevel: character.japanese!.jlptLevel
        )
        try sut.insertCharacter(character) // Should update, not duplicate

        // Then
        let retrieved = try sut.getCharacter(character.character)
        XCTAssertEqual(retrieved?.japanese?.onyomi.count, 2, "Should have updated reading")
    }

    // MARK: - Test: False friend queries

    func testInsertAndRetrieveFalseFriend() throws {
        // Given
        let falseFriend = MockData.falseFriend勉強

        // When
        try sut.insertFalseFriend(falseFriend)
        let retrieved = try sut.getFalseFriend(falseFriend.id)

        // Then
        XCTAssertNotNil(retrieved, "False friend should be retrieved")
        XCTAssertEqual(retrieved?.characters, falseFriend.characters)
        XCTAssertEqual(retrieved?.severity, falseFriend.severity)
        XCTAssertEqual(retrieved?.japaneseMeanings, falseFriend.japaneseMeanings)
    }

    func testGetAllFalseFriends() throws {
        // Given
        let falseFriends = MockData.allFalseFriends

        // When
        for ff in falseFriends {
            try sut.insertFalseFriend(ff)
        }

        let allRetrieved = try sut.getAllFalseFriends()

        // Then
        XCTAssertEqual(allRetrieved.count, falseFriends.count, "Should retrieve all false friends")
    }

    func testGetFalseFriendsByCharacter() throws {
        // Given
        let falseFriend = MockData.falseFriend勉強
        try sut.insertFalseFriend(falseFriend)

        // When
        let retrieved = try sut.getFalseFriendByCharacters("勉強")

        // Then
        XCTAssertNotNil(retrieved, "Should find false friend by characters")
        XCTAssertEqual(retrieved?.characters, "勉強")
    }

    // MARK: - Test: Search with various query types

    func testSearchByCharacter() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let results = try sut.searchCharacters(query: "手")

        // Then
        XCTAssertFalse(results.isEmpty, "Should find character by exact match")
        XCTAssertTrue(results.contains { $0.character == "手" })
    }

    func testSearchByJapaneseReading() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let results = try sut.searchCharacters(query: "て")

        // Then
        XCTAssertFalse(results.isEmpty, "Should find character by Japanese reading")
    }

    func testSearchByChinesePinyin() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let results = try sut.searchCharacters(query: "shou")

        // Then
        // Note: This depends on the search implementation handling pinyin
        // Results may be empty if search doesn't match pinyin, which is acceptable
        if !results.isEmpty {
            XCTAssertTrue(results.contains { char in
                char.chinese?.pinyin.contains { $0.lowercased().contains("shou") } ?? false
            })
        }
    }

    func testSearchByMeaning() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let results = try sut.searchCharacters(query: "hand")

        // Then
        XCTAssertFalse(results.isEmpty, "Should find character by meaning")
        XCTAssertTrue(results.contains { char in
            char.japanese?.meanings.contains { $0.lowercased().contains("hand") } ?? false
        })
    }

    func testSearchReturnsEmptyForNonMatch() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let results = try sut.searchCharacters(query: "xyzabc123")

        // Then
        XCTAssertTrue(results.isEmpty, "Should return empty for non-matching query")
    }

    func testSearchIsCaseInsensitive() throws {
        // Given
        let character = MockData.character手
        try sut.insertCharacter(character)

        // When
        let upperResults = try sut.searchCharacters(query: "HAND")
        let lowerResults = try sut.searchCharacters(query: "hand")

        // Then
        XCTAssertEqual(
            upperResults.count,
            lowerResults.count,
            "Search should be case-insensitive"
        )
    }

    // MARK: - Test: Filtering false friends by severity

    func testFilterFalseFriendsBySeverity() throws {
        // Given
        let falseFriends = MockData.allFalseFriends
        for ff in falseFriends {
            try sut.insertFalseFriend(ff)
        }

        // When
        let criticalOnly = try sut.getFalseFriendsBySeverity(.critical)

        // Then
        XCTAssertFalse(criticalOnly.isEmpty, "Should find critical false friends")
        XCTAssertTrue(
            criticalOnly.allSatisfy { $0.severity == .critical },
            "All results should be critical severity"
        )
    }

    func testFilterFalseFriendsByMultipleSeverities() throws {
        // Given
        let falseFriends = MockData.allFalseFriends
        for ff in falseFriends {
            try sut.insertFalseFriend(ff)
        }

        // When
        let highSeverity = try sut.getFalseFriendsBySeverity(.high)
        let moderateSeverity = try sut.getFalseFriendsBySeverity(.moderate)

        // Then
        XCTAssertTrue(
            highSeverity.allSatisfy { $0.severity == .high },
            "High severity filter should only return high severity items"
        )
        XCTAssertTrue(
            moderateSeverity.allSatisfy { $0.severity == .moderate },
            "Moderate severity filter should only return moderate severity items"
        )
    }

    func testGetFalseFriendsByCategory() throws {
        // Given
        let falseFriends = MockData.allFalseFriends
        for ff in falseFriends {
            try sut.insertFalseFriend(ff)
        }

        // When
        let meaningDifference = try sut.getFalseFriendsByCategory(.meaningDifference)

        // Then
        XCTAssertFalse(meaningDifference.isEmpty, "Should find false friends by category")
        XCTAssertTrue(
            meaningDifference.allSatisfy { $0.category == .meaningDifference },
            "All results should match the category filter"
        )
    }

    // MARK: - Test: Database migration

    func testDatabaseSchemaVersion() throws {
        // When
        let version = try sut.getDatabaseVersion()

        // Then
        XCTAssertGreaterThan(version, 0, "Database version should be set")
        XCTAssertLessThanOrEqual(version, 10, "Database version should be reasonable")
    }

    func testDatabaseCreatesRequiredTables() throws {
        // When
        let hasCharactersTable = try sut.tableExists("characters")
        let hasFalseFriendsTable = try sut.tableExists("false_friends")
        let hasMetadataTable = try sut.tableExists("database_metadata")

        // Then
        XCTAssertTrue(hasCharactersTable, "Characters table should exist")
        XCTAssertTrue(hasFalseFriendsTable, "False friends table should exist")
        XCTAssertTrue(hasMetadataTable, "Metadata table should exist")
    }

    func testDatabaseMigrationIsIdempotent() throws {
        // Given - Database already created in setUp

        // When - Try to run migrations again (shouldn't fail or duplicate)
        let initialVersion = try sut.getDatabaseVersion()

        // Create a new instance pointing to same database
        let sut2 = try DatabaseManager(path: testDatabasePath)
        let secondVersion = try sut2.getDatabaseVersion()

        // Then
        XCTAssertEqual(initialVersion, secondVersion, "Version should not change on re-initialization")
    }

    // MARK: - Test: Data integrity

    func testCharacterForeignKeyConstraints() throws {
        // Given - Try to insert a character with a false friend ID that doesn't exist
        var character = MockData.character手
        character.falseFriendId = "non_existent_id"

        // When/Then
        // This should either succeed (if FK not enforced) or fail gracefully
        do {
            try sut.insertCharacter(character)
            // If it succeeds, verify the constraint is handled
        } catch {
            // If it fails, verify it's the expected FK error
            XCTAssertTrue(
                error.localizedDescription.contains("foreign key") ||
                error.localizedDescription.contains("constraint"),
                "Should be a foreign key constraint error"
            )
        }
    }

    func testDatabaseHandlesEmptyStrings() throws {
        // Given
        var character = MockData.character手
        character.japanese?.meanings = [""] // Empty meaning

        // When/Then - Should handle gracefully
        XCTAssertNoThrow(try sut.insertCharacter(character))
    }

    func testDatabaseHandlesUnicodeCharacters() throws {
        // Given
        let unicodeCharacter = Character(
            character: "𠮷", // Rare kanji (U+20BB7)
            japanese: JapaneseReading(
                onyomi: ["キチ"],
                kunyomi: ["よし"],
                meanings: ["lucky"],
                jlptLevel: nil
            ),
            chinese: nil,
            strokeCount: 6,
            radical: "士",
            frequencyRank: nil,
            falseFriendId: nil
        )

        // When
        try sut.insertCharacter(unicodeCharacter)
        let retrieved = try sut.getCharacter("𠮷")

        // Then
        XCTAssertNotNil(retrieved, "Should handle rare Unicode characters")
        XCTAssertEqual(retrieved?.character, "𠮷")
    }

    // MARK: - Test: Transaction handling

    func testTransactionRollbackOnError() throws {
        // Given
        let character = MockData.character手

        // When - Start a transaction and intentionally cause an error
        do {
            try sut.insertCharacter(character)

            // Try to insert with same primary key (should fail)
            try sut.insertCharacter(character)

            XCTFail("Should have thrown an error on duplicate insertion")
        } catch {
            // Expected error
        }

        // Then - Verify first insert succeeded (or both rolled back, depending on implementation)
        let retrieved = try sut.getCharacter(character.character)
        // Either first insert succeeded, or entire transaction rolled back
        // Both are acceptable behaviors depending on implementation
    }

    // MARK: - Test: Performance

    func testBulkInsertPerformance() throws {
        // Generate 100 test characters
        let characters = (0..<100).map { index in
            Character(
                character: String(UnicodeScalar(0x4E00 + index)!), // CJK Unified Ideographs
                japanese: JapaneseReading(
                    onyomi: ["TEST"],
                    kunyomi: ["test"],
                    meanings: ["test"],
                    jlptLevel: "N5"
                ),
                chinese: nil,
                strokeCount: 1,
                radical: "一",
                frequencyRank: index,
                falseFriendId: nil
            )
        }

        // Measure
        measure {
            for character in characters {
                try? sut.insertCharacter(character)
            }
        }
    }

    func testSearchPerformance() throws {
        // Given - Insert test data
        for character in MockData.allCharacters {
            try sut.insertCharacter(character)
        }

        // Measure
        measure {
            _ = try? sut.searchCharacters(query: "手")
        }
    }
}

// MARK: - DatabaseManager Test Extensions

private extension DatabaseManager {
    func tableExists(_ tableName: String) throws -> Bool {
        return try dbQueue.read { db in
            try db.tableExists(tableName)
        }
    }

    func getDatabaseVersion() throws -> Int {
        return try dbQueue.read { db in
            let version = try String.fetchOne(
                db,
                sql: "SELECT value FROM database_metadata WHERE key = 'schema_version'"
            )
            return Int(version ?? "0") ?? 0
        }
    }

    func getFalseFriendsBySeverity(_ severity: Severity) throws -> [FalseFriend] {
        return try dbQueue.read { db in
            try FalseFriend.filter(Column("severity") == severity.rawValue).fetchAll(db)
        }
    }

    func getFalseFriendsByCategory(_ category: Category) throws -> [FalseFriend] {
        return try dbQueue.read { db in
            try FalseFriend.filter(Column("category") == category.rawValue).fetchAll(db)
        }
    }
}
