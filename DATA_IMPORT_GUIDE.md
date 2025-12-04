# Yomikae: Full Dictionary Data Import Guide

## Overview

This guide covers importing the full character database alongside the curated false friends.

**Data sources:**
- Unihan (Unicode CJK) → stroke counts, radicals, basic readings
- JMDict (Japanese) → meanings, JLPT levels, on/kun readings
- CC-CEDICT (Chinese) → pinyin, meanings, simplified/traditional variants
- Curated false friends → 42 entries with examples and mnemonics

---

## Step 1: Run the Data Pipeline

```bash
cd ~/yomikae-data
python data_pipeline.py --all
```

This downloads source files and generates:
- `output/characters.json` (~3,000 characters)
- `output/false_friends.json` (42 entries) 

---

## Step 2: JSON Structure

### characters.json

```json
[
  {
    "character": "食",
    "japanese": {
      "onyomi": ["ショク", "ジキ"],
      "kunyomi": ["たべる", "くう"],
      "meanings": ["eat", "food", "meal"],
      "jlpt_level": 5
    },
    "chinese": {
      "pinyin": ["shí"],
      "simplified": null,
      "traditional": null,
      "meanings_simplified": ["to eat", "food", "meal"],
      "meanings_traditional": ["to eat", "food", "meal"]
    },
    "stroke_count": 9,
    "radical": "食",
    "frequency_rank": 328,
    "false_friend_id": null
  },
  {
    "character": "手紙",
    "japanese": {
      "onyomi": [],
      "kunyomi": ["てがみ"],
      "meanings": ["letter", "correspondence"],
      "jlpt_level": 5
    },
    "chinese": {
      "pinyin": ["shǒuzhǐ"],
      "simplified": null,
      "traditional": null,
      "meanings_simplified": ["toilet paper"],
      "meanings_traditional": ["toilet paper"]
    },
    "stroke_count": null,
    "radical": null,
    "frequency_rank": null,
    "false_friend_id": "ff_002"
  }
]
```

### false_friends_v2.json

```json
{
  "metadata": { ... },
  "false_friends": [
    {
      "id": "ff_002",
      "characters": "手紙",
      "type": 4,
      "category": "true_divergence",
      "severity": "critical",
      "affects": "both",
      "jp_reading": "てがみ (tegami)",
      "jp_meanings": ["letter", "correspondence"],
      "jp_example": "友達に手紙を書いた。",
      "jp_example_translation": "I wrote a letter to my friend.",
      "cn_pinyin": "shǒuzhǐ",
      "cn_meanings_simplified": ["toilet paper"],
      "cn_meanings_traditional": ["toilet paper"],
      "cn_example": "卫生间的手纸用完了。",
      "cn_example_translation": "The toilet paper ran out.",
      "explanation": "True meaning divergence...",
      "mnemonic_tip": "In Japan write ON paper, in China wipe WITH paper."
    }
  ]
}
```

---

## Step 3: Update Swift Models

### Character.swift (handles both single chars and compounds)

```swift
import Foundation
import GRDB

struct Character: Codable, Identifiable, Hashable, FetchableRecord, PersistableRecord {
    var id: String { character }
    let character: String  // Can be 1+ characters (e.g., "食" or "手紙")
    let japanese: JapaneseReading?
    let chinese: ChineseReading?
    let strokeCount: Int?
    let radical: String?
    let frequencyRank: Int?
    let falseFriendId: String?
    
    var isFalseFriend: Bool { falseFriendId != nil }
    var isCompound: Bool { character.count > 1 }
    
    // GRDB table name
    static let databaseTableName = "characters"
    
    // JSON key mapping
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
    
    // Convenience: primary reading for display
    var primaryReading: String? {
        kunyomi.first ?? onyomi.first
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
    
    // Convenience: primary pinyin for display
    var primaryPinyin: String? {
        pinyin.first
    }
    
    // Get meanings for user's preferred system
    func meanings(for system: ChineseSystem) -> [String] {
        switch system {
        case .simplified: return meaningsSimplified
        case .traditional: return meaningsTraditional
        case .both: return meaningsSimplified // Primary
        }
    }
}
```

---

## Step 4: Update DatabaseManager

```swift
import GRDB

class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue!
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let fileManager = FileManager.default
        let dbPath = getDocumentsDirectory().appendingPathComponent("yomikae.sqlite")
        
        do {
            dbQueue = try DatabaseQueue(path: dbPath.path)
            
            try dbQueue.write { db in
                // Characters table
                try db.create(table: "characters", ifNotExists: true) { t in
                    t.column("character", .text).primaryKey()
                    t.column("japanese", .text)  // JSON blob
                    t.column("chinese", .text)   // JSON blob
                    t.column("stroke_count", .integer)
                    t.column("radical", .text)
                    t.column("frequency_rank", .integer)
                    t.column("false_friend_id", .text)
                }
                
                // False friends table
                try db.create(table: "false_friends", ifNotExists: true) { t in
                    t.column("id", .text).primaryKey()
                    t.column("characters", .text).notNull()
                    t.column("type", .integer)
                    t.column("category", .text)
                    t.column("severity", .text)
                    t.column("affects", .text)
                    t.column("jp_reading", .text)
                    t.column("jp_meanings", .text)  // JSON array
                    t.column("jp_example", .text)
                    t.column("jp_example_translation", .text)
                    t.column("cn_pinyin", .text)
                    t.column("cn_meanings_simplified", .text)  // JSON array
                    t.column("cn_meanings_traditional", .text) // JSON array
                    t.column("cn_example", .text)
                    t.column("cn_example_translation", .text)
                    t.column("explanation", .text)
                    t.column("mnemonic_tip", .text)
                    t.column("traditional_note", .text)
                    t.column("merged_from", .text)  // JSON array
                }
                
                // Indexes for fast search
                try db.create(index: "idx_characters_frequency", on: "characters", columns: ["frequency_rank"], ifNotExists: true)
                try db.create(index: "idx_false_friends_severity", on: "false_friends", columns: ["severity"], ifNotExists: true)
            }
            
            // Import data on first launch
            if try isFirstLaunch() {
                try importBundledData()
            }
            
        } catch {
            fatalError("Database setup failed: \(error)")
        }
    }
    
    private func isFirstLaunch() throws -> Bool {
        try dbQueue.read { db in
            let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM characters")
            return (count ?? 0) == 0
        }
    }
    
    private func importBundledData() throws {
        // Import characters
        if let url = Bundle.main.url(forResource: "characters", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let characters = try JSONDecoder().decode([Character].self, from: data)
            try dbQueue.write { db in
                for character in characters {
                    try character.insert(db)
                }
            }
            print("Imported \(characters.count) characters")
        }
        
        // Import false friends
        if let url = Bundle.main.url(forResource: "false_friends_v2", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let wrapper = try JSONDecoder().decode(FalseFriendsWrapper.self, from: data)
            try dbQueue.write { db in
                for ff in wrapper.falseFriends {
                    try ff.insert(db)
                }
            }
            print("Imported \(wrapper.falseFriends.count) false friends")
        }
    }
    
    // ... rest of DatabaseManager
}

struct FalseFriendsWrapper: Codable {
    let metadata: FalseFriendsMetadata
    let falseFriends: [FalseFriend]
    
    enum CodingKeys: String, CodingKey {
        case metadata
        case falseFriends = "false_friends"
    }
}

struct FalseFriendsMetadata: Codable {
    let version: String
    let description: String
    let totalEntries: Int
    
    enum CodingKeys: String, CodingKey {
        case version
        case description
        case totalEntries = "total_entries"
    }
}
```

---

## Step 5: Update Search to Query Full Database

```swift
class CharacterRepository {
    private let db = DatabaseManager.shared
    
    /// Search characters by kanji, reading, pinyin, or English meaning
    func search(query: String, limit: Int = 50) throws -> [Character] {
        let pattern = "%\(query)%"
        
        return try db.read { db in
            try Character.fetchAll(db, sql: """
                SELECT * FROM characters
                WHERE character LIKE ?
                   OR japanese LIKE ?
                   OR chinese LIKE ?
                ORDER BY 
                    CASE WHEN character = ? THEN 0 ELSE 1 END,
                    frequency_rank ASC NULLS LAST
                LIMIT ?
                """,
                arguments: [pattern, pattern, pattern, query, limit]
            )
        }
    }
    
    /// Get all false friend characters
    func getFalseFriendCharacters() throws -> [Character] {
        return try db.read { db in
            try Character.fetchAll(db, sql: """
                SELECT * FROM characters
                WHERE false_friend_id IS NOT NULL
                ORDER BY frequency_rank ASC NULLS LAST
                """)
        }
    }
    
    /// Get character by exact match
    func getCharacter(_ char: String) throws -> Character? {
        return try db.read { db in
            try Character.fetchOne(db, key: char)
        }
    }
}
```

---

## Step 6: Fix Multi-Character Display

The truncation bug is likely here. Update the character display to handle compounds:

```swift
// In any view showing the character:

Text(character.character)
    .font(.system(size: character.isCompound ? 48 : 72))  // Smaller for compounds
    .minimumScaleFactor(0.5)  // Allow shrinking if needed
    .lineLimit(1)
    .fixedSize(horizontal: true, vertical: false)  // Don't truncate!
```

Or for FalseFriendRow:

```swift
struct FalseFriendRow: View {
    let falseFriend: FalseFriend
    
    var body: some View {
        HStack(spacing: 12) {
            // Character - FIXED SIZE, no truncation
            Text(falseFriend.characters)
                .font(.system(size: 32, weight: .medium))
                .frame(minWidth: 60, alignment: .center)  // Min width, not fixed
            
            VStack(alignment: .leading, spacing: 4) {
                // Japanese meaning
                HStack(spacing: 4) {
                    Text("🇯🇵")
                    Text(falseFriend.jpMeanings.first ?? "")
                        .fontWeight(.medium)
                }
                
                // Chinese meaning  
                HStack(spacing: 4) {
                    Text("🇨🇳")
                    Text(falseFriend.cnMeaningsSimplified.first ?? "")
                        .foregroundStyle(.secondary)
                }
                
                // Readings
                Text("\(falseFriend.jpReading) · \(falseFriend.cnPinyin)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // Severity badge
            FalseFriendBadge(falseFriend: falseFriend)
        }
        .padding(.vertical, 4)
    }
}
```

---

## File Checklist

Copy these files into your Xcode project's Resources folder:
- [ ] `characters.json` (from pipeline output)
- [ ] `false_friends_v2.json` (from /mnt/user-data/outputs/)

Update these Swift files:
- [ ] `Character.swift` — Add isCompound, update CodingKeys
- [ ] `ChineseReading.swift` — Add meaningsSimplified/Traditional
- [ ] `DatabaseManager.swift` — Import both JSON files
- [ ] `CharacterRepository.swift` — Full-text search
- [ ] `FalseFriendRow.swift` — Fix truncation
- [ ] `FalseFriendDetailView.swift` — Show pinyin and readings

---

## Testing

After import, verify:
```swift
// In a test or debug view:
let repo = CharacterRepository()

// Should return many results
let results = try repo.search(query: "食")
print("Found \(results.count) results for 食")

// Should find multi-char compounds
let tegami = try repo.getCharacter("手紙")
print("手紙 is false friend: \(tegami?.isFalseFriend ?? false)")

// Should return 42 items
let ffChars = try repo.getFalseFriendCharacters()
print("False friend characters: \(ffChars.count)")
```
