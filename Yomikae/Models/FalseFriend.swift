import Foundation
import SwiftUI
import GRDB

struct FalseFriend: Codable, Identifiable, Hashable {
    let id: String
    let character: String
    let jpReading: String
    let jpMeanings: [String]
    let cnPinyin: String
    let cnCharacters: String?  // Chinese simplified form if different from JP
    let cnMeaningsSimplified: [String]
    let cnMeaningsTraditional: [String]
    let severity: Severity
    let category: Category
    let affectedSystem: AffectedSystem
    let explanation: String
    let examples: [Example]
    let traditionalNote: String?
    let mergedFrom: [String]?
    // Structured meanings from JCKV
    let sharedMeanings: [String]?
    let jpOnlyMeanings: [String]?
    let cnOnlyMeanings: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case character
        case jpReading = "jp_reading"
        case jpMeanings = "jp_meanings"
        case cnPinyin = "cn_pinyin"
        case cnCharacters = "cn_characters"
        case cnMeaningsSimplified = "cn_meanings_simplified"
        case cnMeaningsTraditional = "cn_meanings_traditional"
        case severity
        case category
        case affectedSystem = "affected_system"
        case explanation
        case examples
        case traditionalNote = "traditional_note"
        case mergedFrom = "merged_from"
        case sharedMeanings = "shared_meanings"
        case jpOnlyMeanings = "jp_only_meanings"
        case cnOnlyMeanings = "cn_only_meanings"
    }

    // Custom initializer with defaults for new optional fields
    init(
        id: String,
        character: String,
        jpReading: String,
        jpMeanings: [String],
        cnPinyin: String,
        cnCharacters: String? = nil,
        cnMeaningsSimplified: [String],
        cnMeaningsTraditional: [String],
        severity: Severity,
        category: Category,
        affectedSystem: AffectedSystem,
        explanation: String,
        examples: [Example],
        traditionalNote: String?,
        mergedFrom: [String]?,
        sharedMeanings: [String]? = nil,
        jpOnlyMeanings: [String]? = nil,
        cnOnlyMeanings: [String]? = nil
    ) {
        self.id = id
        self.character = character
        self.jpReading = jpReading
        self.jpMeanings = jpMeanings
        self.cnPinyin = cnPinyin
        self.cnCharacters = cnCharacters
        self.cnMeaningsSimplified = cnMeaningsSimplified
        self.cnMeaningsTraditional = cnMeaningsTraditional
        self.severity = severity
        self.category = category
        self.affectedSystem = affectedSystem
        self.explanation = explanation
        self.examples = examples
        self.traditionalNote = traditionalNote
        self.mergedFrom = mergedFrom
        self.sharedMeanings = sharedMeanings
        self.jpOnlyMeanings = jpOnlyMeanings
        self.cnOnlyMeanings = cnOnlyMeanings
    }

    // Helper method to check if this false friend is relevant for a given Chinese system
    func isRelevant(for system: ChineseSystem) -> Bool {
        switch affectedSystem {
        case .both:
            return true
        case .simplifiedOnly:
            return system == .simplified || system == .both
        case .traditionalOnly:
            return system == .traditional || system == .both
        }
    }

    // Helper method to get the appropriate Chinese meanings for a given system
    func cnMeanings(for system: ChineseSystem) -> [String] {
        switch system {
        case .simplified:
            return cnMeaningsSimplified
        case .traditional:
            return cnMeaningsTraditional
        case .both:
            // Return combined meanings, removing duplicates
            return Array(Set(cnMeaningsSimplified + cnMeaningsTraditional))
        }
    }
}

// GRDB Conformance
extension FalseFriend: FetchableRecord, PersistableRecord {}

enum Severity: String, Codable, CaseIterable {
    case critical = "critical"
    case important = "important"
    case subtle = "subtle"

    var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .important: return "Important"
        case .subtle: return "Subtle"
        }
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .subtle: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .important: return "exclamationmark.circle.fill"
        case .subtle: return "info.circle.fill"
        }
    }
}

enum Category: String, Codable, CaseIterable {
    case trueDivergence = "true_divergence"
    case simplificationMerge = "simplification_merge"
    case japaneseCoinage = "japanese_coinage"
    case scopeDifference = "scope_difference"

    var displayName: String {
        switch self {
        case .trueDivergence: return "True Divergence"
        case .simplificationMerge: return "Simplification Merge"
        case .japaneseCoinage: return "Japanese Coinage"
        case .scopeDifference: return "Scope Difference"
        }
    }

    var description: String {
        switch self {
        case .trueDivergence:
            return "Meanings diverged over time in Japanese and Chinese"
        case .simplificationMerge:
            return "Character simplification merged distinct traditional characters"
        case .japaneseCoinage:
            return "Character created or repurposed in Japan"
        case .scopeDifference:
            return "Similar meanings but different usage scope or connotation"
        }
    }
}

enum AffectedSystem: String, Codable, CaseIterable {
    case both = "both"
    case simplifiedOnly = "simplified_only"
    case traditionalOnly = "traditional_only"

    var displayName: String {
        switch self {
        case .both: return "Both Systems"
        case .simplifiedOnly: return "Simplified Only"
        case .traditionalOnly: return "Traditional Only"
        }
    }

    var description: String {
        switch self {
        case .both:
            return "Affects both simplified and traditional Chinese readers"
        case .simplifiedOnly:
            return "Only affects simplified Chinese readers"
        case .traditionalOnly:
            return "Only affects traditional Chinese readers"
        }
    }
}

struct Example: Codable, Hashable {
    let japanese: String
    let chineseSimplified: String
    let chineseTraditional: String
    let translation: String

    enum CodingKeys: String, CodingKey {
        case japanese
        case chineseSimplified = "chinese_simplified"
        case chineseTraditional = "chinese_traditional"
        case translation
    }
}
