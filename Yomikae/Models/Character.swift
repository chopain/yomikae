import Foundation
import GRDB

struct Character: Codable, Identifiable, Hashable {
    var id: String { character }
    let character: String
    let japanese: JapaneseReading?
    let chinese: ChineseReading?
    let strokeCount: Int?
    let radical: String?
    let frequencyRank: Int?
    let falseFriendId: String?

    var isFalseFriend: Bool { falseFriendId != nil }

    enum CodingKeys: String, CodingKey {
        case character
        case japanese
        case chinese
        case strokeCount = "stroke_count"
        case radical
        case frequencyRank = "frequency_rank"
        case falseFriendId = "false_friend_id"
    }
}

// GRDB Conformance
extension Character: FetchableRecord, PersistableRecord {}

struct JapaneseReading: Codable, Hashable {
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
}

struct ChineseReading: Codable, Hashable {
    let pinyin: [String]
    let simplified: String?
    let traditional: String?
    let meaningsSimplified: [String]
    let meaningsTraditional: [String]

    enum CodingKeys: String, CodingKey {
        case pinyin
        case simplified
        case traditional
        case meaningsSimplified = "meanings_simplified"
        case meaningsTraditional = "meanings_traditional"
    }
}
