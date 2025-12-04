import Foundation

// MARK: - JSON Models for Import (v2 Format)

/// Metadata wrapper for false_friends_v2.json
struct FalseFriendsJSONWrapper: Codable {
    let metadata: FalseFriendsMetadata
    let falseFriends: [FalseFriendJSONV2]

    enum CodingKeys: String, CodingKey {
        case metadata
        case falseFriends = "false_friends"
    }
}

/// Metadata about the false friends database
struct FalseFriendsMetadata: Codable {
    let version: String
    let description: String
    let totalEntries: Int
    let categories: [String: String]

    enum CodingKeys: String, CodingKey {
        case version
        case description
        case totalEntries = "total_entries"
        case categories
    }
}

/// JSON representation of a false friend (v2 format) for import
struct FalseFriendJSONV2: Codable {
    let id: String
    let characters: String
    let type: Int
    let category: String
    let severity: String
    let affects: String
    let traditionalNote: String?
    let mergedFrom: [String]?
    let jpReading: String
    let jpMeanings: [String]
    let jpExample: String
    let jpExampleTranslation: String
    let cnPinyin: String
    let cnMeaningsSimplified: [String]
    let cnMeaningsTraditional: [String]
    let cnExample: String
    let cnExampleTranslation: String
    let explanation: String
    let mnemonicTip: String?

    enum CodingKeys: String, CodingKey {
        case id
        case characters
        case type
        case category
        case severity
        case affects
        case traditionalNote = "traditional_note"
        case mergedFrom = "merged_from"
        case jpReading = "jp_reading"
        case jpMeanings = "jp_meanings"
        case jpExample = "jp_example"
        case jpExampleTranslation = "jp_example_translation"
        case cnPinyin = "cn_pinyin"
        case cnMeaningsSimplified = "cn_meanings_simplified"
        case cnMeaningsTraditional = "cn_meanings_traditional"
        case cnExample = "cn_example"
        case cnExampleTranslation = "cn_example_translation"
        case explanation
        case mnemonicTip = "mnemonic_tip"
    }

    /// Convert JSON model to database model
    func toFalseFriend() throws -> FalseFriend {
        // Parse severity
        guard let severityEnum = Severity(rawValue: severity) else {
            throw JSONImportError.invalidValue(field: "severity", value: severity)
        }

        // Parse category - use Category not FalseFriendCategory
        guard let categoryEnum = Category(rawValue: category) else {
            throw JSONImportError.invalidValue(field: "category", value: category)
        }

        // Parse affected system (v2 uses "affects", model uses "affectedSystem")
        let affectedSystemValue: String
        switch affects {
        case "simplified_only":
            affectedSystemValue = "simplified_only"
        case "traditional_only":
            affectedSystemValue = "traditional_only"
        case "both":
            affectedSystemValue = "both"
        default:
            throw JSONImportError.invalidValue(field: "affects", value: affects)
        }

        guard let affectedSystemEnum = AffectedSystem(rawValue: affectedSystemValue) else {
            throw JSONImportError.invalidValue(field: "affected_system", value: affectedSystemValue)
        }

        // Build examples array using the Example struct
        let examples = [
            Example(
                japanese: jpExample,
                chineseSimplified: cnExample,
                chineseTraditional: cnExample, // v2 format doesn't distinguish, use same
                translation: jpExampleTranslation
            )
        ]

        return FalseFriend(
            id: id,
            character: characters,
            jpReading: jpReading,
            jpMeanings: jpMeanings,
            cnPinyin: cnPinyin,
            cnMeaningsSimplified: cnMeaningsSimplified,
            cnMeaningsTraditional: cnMeaningsTraditional,
            severity: severityEnum,
            category: categoryEnum,
            affectedSystem: affectedSystemEnum,
            explanation: explanation,
            examples: examples,
            traditionalNote: traditionalNote,
            mergedFrom: mergedFrom
        )
    }
}

/// JSON representation of Japanese reading data
struct JapaneseDataJSON: Codable {
    let onyomi: [String]
    let kunyomi: [String]
    let meanings: [String]
    let jlptLevel: Int?

    enum CodingKeys: String, CodingKey {
        case onyomi
        case kunyomi
        case meanings
        case jlptLevel = "jlpt_level"
    }

    /// Convert to database model
    func toJapaneseReading() -> JapaneseReading {
        return JapaneseReading(
            onyomi: onyomi,
            kunyomi: kunyomi,
            meanings: meanings,
            jlptLevel: jlptLevel
        )
    }
}

/// JSON representation of Chinese reading data
struct ChineseDataJSON: Codable {
    let pinyin: [String]
    let meanings: [String]
    let simplified: String?
    let traditional: String?

    /// Convert to database model
    func toChineseReading() -> ChineseReading {
        return ChineseReading(
            pinyin: pinyin,
            simplified: simplified,
            traditional: traditional,
            meaningsSimplified: meanings,
            meaningsTraditional: meanings
        )
    }
}

/// JSON representation of a character for import
struct CharacterJSON: Codable {
    let character: String
    let japanese: JapaneseDataJSON?
    let chinese: ChineseDataJSON?
    let strokeCount: Int?
    let radical: String?
    let frequencyRank: Int?
    let falseFriendId: String?

    enum CodingKeys: String, CodingKey {
        case character
        case japanese
        case chinese
        case strokeCount = "stroke_count"
        case radical
        case frequencyRank = "frequency_rank"
        case falseFriendId = "false_friend_id"
    }

    /// Convert JSON model to database model
    func toCharacter() -> Character {
        return Character(
            character: character,
            japanese: japanese?.toJapaneseReading(),
            chinese: chinese?.toChineseReading(),
            strokeCount: strokeCount,
            radical: radical,
            frequencyRank: frequencyRank,
            falseFriendId: falseFriendId
        )
    }
}

// MARK: - Import Errors

enum JSONImportError: LocalizedError {
    case fileNotFound(String)
    case invalidJSON(String)
    case invalidValue(field: String, value: String)
    case decodingError(Error)
    case databaseError(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file not found: \(filename)"
        case .invalidJSON(let filename):
            return "Invalid JSON format in file: \(filename)"
        case .invalidValue(let field, let value):
            return "Invalid value for \(field): \(value)"
        case .decodingError(let error):
            return "Failed to decode JSON: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error during import: \(error.localizedDescription)"
        }
    }
}

// MARK: - JSON Import Service

class JSONImportService {

    /// Import false friends from JSON file (v2 format)
    static func importFalseFriends(from filename: String = "false_friends_v2") throws -> [FalseFriend] {
        let jsonData = try loadJSONFile(filename)

        do {
            let decoder = JSONDecoder()
            let wrapper = try decoder.decode(FalseFriendsJSONWrapper.self, from: jsonData)

            print("📦 Loading false friends database version \(wrapper.metadata.version)")
            print("📋 Total entries: \(wrapper.metadata.totalEntries)")

            // Convert to database models
            var falseFriends: [FalseFriend] = []
            for (index, jsonModel) in wrapper.falseFriends.enumerated() {
                do {
                    let falseFriend = try jsonModel.toFalseFriend()
                    falseFriends.append(falseFriend)
                } catch {
                    print("⚠️ Warning: Skipping false friend at index \(index) (\(jsonModel.id)) due to error: \(error)")
                    // Continue with other entries instead of failing completely
                }
            }

            print("✅ Successfully imported \(falseFriends.count) false friends from JSON")
            return falseFriends

        } catch {
            throw JSONImportError.decodingError(error)
        }
    }

    /// Import characters from JSON file
    static func importCharacters(from filename: String = "characters") throws -> [Character] {
        let jsonData = try loadJSONFile(filename)

        do {
            let decoder = JSONDecoder()
            let charactersJSON = try decoder.decode([CharacterJSON].self, from: jsonData)

            // Convert to database models
            let characters = charactersJSON.map { $0.toCharacter() }

            print("✅ Successfully imported \(characters.count) characters from JSON")
            return characters

        } catch {
            throw JSONImportError.decodingError(error)
        }
    }

    /// Load JSON file from bundle
    private static func loadJSONFile(_ filename: String) throws -> Data {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JSONImportError.fileNotFound(filename + ".json")
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw JSONImportError.invalidJSON(filename + ".json")
        }
    }
}

// MARK: - Import Progress Tracking

struct ImportProgress {
    var totalItems: Int = 0
    var importedItems: Int = 0
    var failedItems: Int = 0
    var currentItem: String?

    var percentage: Double {
        guard totalItems > 0 else { return 0 }
        return Double(importedItems + failedItems) / Double(totalItems) * 100
    }

    var isComplete: Bool {
        return (importedItems + failedItems) >= totalItems
    }
}

// MARK: - Validation Helpers

extension FalseFriendJSONV2 {
    /// Validate the JSON data
    func validate() throws {
        // Check required fields
        guard !characters.isEmpty else {
            throw JSONImportError.invalidValue(field: "characters", value: "empty")
        }

        guard !jpMeanings.isEmpty else {
            throw JSONImportError.invalidValue(field: "jp_meanings", value: "empty array")
        }

        guard !cnMeaningsSimplified.isEmpty else {
            throw JSONImportError.invalidValue(field: "cn_meanings_simplified", value: "empty array")
        }

        guard !cnMeaningsTraditional.isEmpty else {
            throw JSONImportError.invalidValue(field: "cn_meanings_traditional", value: "empty array")
        }

        // Validate severity
        guard Severity(rawValue: severity) != nil else {
            throw JSONImportError.invalidValue(field: "severity", value: severity)
        }

        // Validate category - use Category not FalseFriendCategory
        guard Category(rawValue: category) != nil else {
            throw JSONImportError.invalidValue(field: "category", value: category)
        }

        // Validate affects
        guard ["simplified_only", "traditional_only", "both"].contains(affects) else {
            throw JSONImportError.invalidValue(field: "affects", value: affects)
        }
    }
}

extension CharacterJSON {
    /// Validate the JSON data
    func validate() throws {
        guard !character.isEmpty else {
            throw JSONImportError.invalidValue(field: "character", value: "empty")
        }
    }
}
