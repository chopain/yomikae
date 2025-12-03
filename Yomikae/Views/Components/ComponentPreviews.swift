import SwiftUI

// MARK: - SearchView Previews

#Preview("SearchView - Empty") {
    SearchView()
}

#Preview("SearchView - With Results") {
    let viewModel = SearchViewModel()
    // Note: In a real preview, we'd inject mock data
    return SearchView()
}

// MARK: - CharacterDetailView Previews

#Preview("CharacterDetailView - Normal Character") {
    CharacterDetailView(character: PreviewData.character手)
}

#Preview("CharacterDetailView - False Friend") {
    CharacterDetailView(character: PreviewData.characterWithFalseFriend)
}

#Preview("CharacterDetailView - Minimal Data") {
    CharacterDetailView(character: PreviewData.minimalCharacter)
}

// MARK: - FalseFriendBanner Previews

#Preview("FalseFriendBanner - Critical") {
    FalseFriendBanner(severity: .critical)
        .padding()
}

#Preview("FalseFriendBanner - High") {
    FalseFriendBanner(severity: .high)
        .padding()
}

#Preview("FalseFriendBanner - Moderate") {
    FalseFriendBanner(severity: .moderate)
        .padding()
}

#Preview("FalseFriendBanner - Low") {
    FalseFriendBanner(severity: .low)
        .padding()
}

// MARK: - FalseFriendDetailView Previews

#Preview("FalseFriendDetailView - Full Data") {
    NavigationStack {
        FalseFriendDetailView(falseFriend: PreviewData.falseFriend勉強)
    }
}

#Preview("FalseFriendDetailView - Multiple Examples") {
    NavigationStack {
        FalseFriendDetailView(falseFriend: PreviewData.falseFriendWithMultipleExamples)
    }
}

// MARK: - SearchBar Previews

#Preview("SearchBar - Empty") {
    struct PreviewWrapper: View {
        @State private var text = ""

        var body: some View {
            SearchBar(text: $text, placeholder: "Search by character or meaning...")
                .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("SearchBar - With Text") {
    struct PreviewWrapper: View {
        @State private var text = "手"

        var body: some View {
            SearchBar(text: $text, placeholder: "Search...")
                .padding()
        }
    }

    return PreviewWrapper()
}

// MARK: - ReadingSection Previews

#Preview("ReadingSection - Japanese") {
    ReadingSection(
        title: "Japanese",
        readings: ["シュ (shu)", "て (te)"],
        meanings: ["hand"],
        color: .blue
    )
    .padding()
}

#Preview("ReadingSection - Chinese") {
    ReadingSection(
        title: "Chinese",
        readings: ["shǒu"],
        meanings: ["hand", "skill", "ability"],
        color: .orange
    )
    .padding()
}

// MARK: - LoadingView Previews

#Preview("LoadingView") {
    LoadingView()
}

#Preview("LoadingView - Dark Mode") {
    LoadingView()
        .preferredColorScheme(.dark)
}

// MARK: - EmptyStateView Previews

#Preview("EmptyStateView - No Results") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No Results",
        message: "Try searching for a different character"
    )
}

#Preview("EmptyStateView - No History") {
    EmptyStateView(
        icon: "clock",
        title: "No History",
        message: "Your search history will appear here"
    )
}

// MARK: - FalseFriendsListView Previews

#Preview("FalseFriendsListView - With Data") {
    NavigationStack {
        FalseFriendsListView()
    }
}

// MARK: - Preview Data

enum PreviewData {
    // Normal character
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

    // Character that is a false friend
    static let characterWithFalseFriend = Character(
        character: "娘",
        japanese: JapaneseReading(
            onyomi: ["ジョウ"],
            kunyomi: ["むすめ"],
            meanings: ["daughter", "girl", "young woman"],
            jlptLevel: "N3"
        ),
        chinese: ChineseReading(
            pinyin: ["niáng"],
            simplified: "niáng",
            traditional: "娘",
            meaningsSimplified: ["mother", "young woman", "miss"],
            meaningsTraditional: ["mother", "young woman", "miss"]
        ),
        strokeCount: 10,
        radical: "女",
        frequencyRank: 500,
        falseFriendId: "ff_niang"
    )

    // Minimal character (only required fields)
    static let minimalCharacter = Character(
        character: "一",
        japanese: JapaneseReading(
            onyomi: ["イチ", "イツ"],
            kunyomi: ["ひと"],
            meanings: ["one"],
            jlptLevel: "N5"
        ),
        chinese: ChineseReading(
            pinyin: ["yī"],
            simplified: "yī",
            traditional: "一",
            meaningsSimplified: ["one"],
            meaningsTraditional: ["one"]
        ),
        strokeCount: 1,
        radical: "一",
        frequencyRank: 1,
        falseFriendId: nil
    )

    // False friend with full data
    static let falseFriend勉強 = FalseFriend(
        id: "ff_benkyou",
        characters: "勉強",
        japaneseMeanings: ["to study", "study", "diligence", "discount"],
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
        notes: "One of the most critical false friends. In Japanese, 勉強 means 'to study', but in Chinese it means 'reluctantly' or 'to force oneself'. This can lead to very confusing misunderstandings."
    )

    // False friend with multiple examples
    static let falseFriendWithMultipleExamples = FalseFriend(
        id: "ff_dajia",
        characters: "大家",
        japaneseMeanings: ["rich family", "master", "expert", "authority"],
        chineseMeaningsSimplified: ["everyone", "all of us", "we all"],
        chineseMeaningsTraditional: ["everyone", "all of us", "we all"],
        severity: .moderate,
        category: .meaningDifference,
        affectedSystem: .both,
        examples: [
            Example(
                japanese: "彼は書道の大家です。",
                chineseSimplified: "大家好！",
                chineseTraditional: "大家好！",
                translation: "JP: He is a master of calligraphy. | CN: Hello everyone!"
            ),
            Example(
                japanese: "大家の作品を展示する。",
                chineseSimplified: "大家都来了。",
                chineseTraditional: "大家都來了。",
                translation: "JP: Display the master's works. | CN: Everyone came."
            ),
            Example(
                japanese: "この分野の大家に相談する。",
                chineseSimplified: "大家一起努力吧！",
                chineseTraditional: "大家一起努力吧！",
                translation: "JP: Consult an authority in this field. | CN: Let's all work hard together!"
            )
        ],
        notes: "In Japanese, 大家 refers to a master or expert in a particular field. In Chinese, it's commonly used to mean 'everyone' or 'all of us'. This is a moderate-severity false friend because the context usually makes the meaning clear."
    )

    // Search results mock
    static let searchResults: [Character] = [
        character手,
        characterWithFalseFriend,
        minimalCharacter
    ]

    // False friends list mock
    static let falseFriendsList: [FalseFriend] = [
        falseFriend勉強,
        FalseFriend(
            id: "ff_niang",
            characters: "娘",
            japaneseMeanings: ["daughter", "girl"],
            chineseMeaningsSimplified: ["mother", "young woman"],
            chineseMeaningsTraditional: ["mother", "young woman"],
            severity: .high,
            category: .meaningDifference,
            affectedSystem: .both,
            examples: [],
            notes: "In Japanese, 娘 means 'daughter', but in Chinese it means 'mother'."
        ),
        falseFriendWithMultipleExamples
    ]
}
