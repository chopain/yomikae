import Foundation
@testable import Yomikae

/// Mock data for testing
enum MockData {
    // MARK: - Characters

    static let character手 = Character(
        character: "手",
        japanese: JapaneseReading(
            onyomi: ["シュ"],
            kunyomi: ["て", "た"],
            meanings: ["hand"],
            jlptLevel: "N5"
        ),
        chinese: ChineseReading(
            pinyin: ["shǒu"],
            simplified: "shǒu",
            traditional: "shǒu",
            meaningsSimplified: ["hand", "skill"],
            meaningsTraditional: ["hand", "skill"]
        ),
        strokeCount: 4,
        radical: "手",
        frequencyRank: 100,
        falseFriendId: nil
    )

    static let character日 = Character(
        character: "日",
        japanese: JapaneseReading(
            onyomi: ["ニチ", "ジツ"],
            kunyomi: ["ひ", "か"],
            meanings: ["day", "sun", "Japan"],
            jlptLevel: "N5"
        ),
        chinese: ChineseReading(
            pinyin: ["rì"],
            simplified: "rì",
            traditional: "rì",
            meaningsSimplified: ["day", "sun", "date"],
            meaningsTraditional: ["day", "sun", "date"]
        ),
        strokeCount: 4,
        radical: "日",
        frequencyRank: 5,
        falseFriendId: nil
    )

    static let character学 = Character(
        character: "学",
        japanese: JapaneseReading(
            onyomi: ["ガク"],
            kunyomi: ["まなぶ"],
            meanings: ["learning", "science"],
            jlptLevel: "N5"
        ),
        chinese: ChineseReading(
            pinyin: ["xué"],
            simplified: "xué",
            traditional: "學",
            meaningsSimplified: ["study", "learn", "school"],
            meaningsTraditional: ["study", "learn", "school"]
        ),
        strokeCount: 8,
        radical: "子",
        frequencyRank: 20,
        falseFriendId: nil
    )

    static let allCharacters: [Character] = [
        character手,
        character日,
        character学
    ]

    // MARK: - False Friends

    static let falseFriend勉強 = FalseFriend(
        id: "ff_benkyou",
        characters: "勉強",
        japaneseMeanings: ["to study", "study", "diligence"],
        chineseMeaningsSimplified: ["reluctantly", "to force oneself", "to do with difficulty"],
        chineseMeaningsTraditional: ["reluctantly", "to force oneself", "to do with difficulty"],
        severity: .critical,
        category: .meaningDifference,
        affectedSystem: .both,
        examples: [
            Example(
                japanese: "毎日日本語を勉強します。",
                chineseSimplified: "他勉强答应了这个要求。",
                chineseTraditional: "他勉強答應了這個要求。",
                translation: "JP: I study Japanese every day. | CN: He reluctantly agreed to this request."
            )
        ],
        notes: "One of the most critical false friends. In Japanese, 勉強 means 'to study', but in Chinese it means 'reluctantly' or 'to force oneself'."
    )

    static let falseFriend娘 = FalseFriend(
        id: "ff_niang",
        characters: "娘",
        japaneseMeanings: ["daughter", "girl"],
        chineseMeaningsSimplified: ["mother", "young woman"],
        chineseMeaningsTraditional: ["mother", "young woman"],
        severity: .high,
        category: .meaningDifference,
        affectedSystem: .both,
        examples: [
            Example(
                japanese: "彼の娘は大学生です。",
                chineseSimplified: "我娘今天不在家。",
                chineseTraditional: "我娘今天不在家。",
                translation: "JP: His daughter is a university student. | CN: My mother is not at home today."
            )
        ],
        notes: "In Japanese, 娘 means 'daughter', but in Chinese it means 'mother'."
    )

    static let falseFriend大家 = FalseFriend(
        id: "ff_dajia",
        characters: "大家",
        japaneseMeanings: ["rich family", "master", "expert"],
        chineseMeaningsSimplified: ["everyone", "all of us"],
        chineseMeaningsTraditional: ["everyone", "all of us"],
        severity: .moderate,
        category: .meaningDifference,
        affectedSystem: .both,
        examples: [
            Example(
                japanese: "彼は書道の大家です。",
                chineseSimplified: "大家好！",
                chineseTraditional: "大家好！",
                translation: "JP: He is a master of calligraphy. | CN: Hello everyone!"
            )
        ],
        notes: "In Japanese, 大家 means 'master/expert', but in Chinese it's commonly used to mean 'everyone'."
    )

    static let falseFriend手紙 = FalseFriend(
        id: "ff_shouzhi",
        characters: "手紙",
        japaneseMeanings: ["letter", "mail"],
        chineseMeaningsSimplified: ["toilet paper"],
        chineseMeaningsTraditional: ["toilet paper"],
        severity: .low,
        category: .meaningDifference,
        affectedSystem: .both,
        examples: [
            Example(
                japanese: "友達に手紙を書きました。",
                chineseSimplified: "请递给我手纸。",
                chineseTraditional: "請遞給我手紙。",
                translation: "JP: I wrote a letter to my friend. | CN: Please pass me the toilet paper."
            )
        ],
        notes: "A humorous false friend. In Japanese, 手紙 means 'letter', but in Chinese it means 'toilet paper'."
    )

    static let allFalseFriends: [FalseFriend] = [
        falseFriend勉強,
        falseFriend娘,
        falseFriend大家,
        falseFriend手紙
    ]

    // MARK: - Search Results

    static let searchResults手: [Character] = [character手]
    static let searchResults学: [Character] = [character学]
    static let emptySearchResults: [Character] = []
}
