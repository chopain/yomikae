import SwiftUI

struct SearchResultRow: View {
    let character: Character

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Large character display
            ZStack(alignment: .topTrailing) {
                Text(character.character)
                    .font(.system(size: characterFontSize, weight: .regular))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .frame(width: characterFrameWidth, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )

                // False friend indicator
                if character.isFalseFriend {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 4, y: -4)
                }
            }

            // Character information
            VStack(alignment: .leading, spacing: 6) {
                // Japanese reading
                if let japanese = character.japanese, !japanese.onyomi.isEmpty || !japanese.kunyomi.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "jp.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)

                        Text(japaneseReading)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }

                // Chinese pinyin
                if let chinese = character.chinese, !chinese.pinyin.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "character.book.closed.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)

                        Text(chinese.pinyin.first ?? "")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }

                // First meaning
                if let meaning = firstMeaning {
                    Text(meaning)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Frequency indicator (if available)
                if let rank = character.frequencyRank {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10))
                        Text("Rank: \(rank)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }

    // MARK: - Computed Properties

    /// Dynamic font size based on character count
    private var characterFontSize: CGFloat {
        character.character.count == 1 ? 36 : 28
    }

    /// Frame width based on character count - wider for compounds
    private var characterFrameWidth: CGFloat {
        let count = character.character.count
        if count == 1 {
            return 56
        } else if count == 2 {
            return 72
        } else {
            return 88
        }
    }

    /// Returns the first available Japanese reading (prioritizes on'yomi)
    private var japaneseReading: String {
        guard let japanese = character.japanese else { return "" }

        if !japanese.onyomi.isEmpty {
            return japanese.onyomi.first ?? ""
        } else if !japanese.kunyomi.isEmpty {
            return japanese.kunyomi.first ?? ""
        }
        return ""
    }

    /// Returns the first available meaning (prioritizes Japanese, then Chinese)
    private var firstMeaning: String? {
        // Try Japanese meanings first
        if let japanese = character.japanese, !japanese.meanings.isEmpty {
            return japanese.meanings.first
        }

        // Fall back to Chinese meanings
        if let chinese = character.chinese {
            if !chinese.meaningsSimplified.isEmpty {
                return chinese.meaningsSimplified.first
            }
            if !chinese.meaningsTraditional.isEmpty {
                return chinese.meaningsTraditional.first
            }
        }

        return nil
    }
}

// MARK: - Preview

#Preview("Standard Character") {
    let character = Character(
        character: "学",
        japanese: JapaneseReading(
            onyomi: ["ガク", "ガッ"],
            kunyomi: ["まな.ぶ"],
            meanings: ["study", "learning", "science"],
            jlptLevel: 5
        ),
        chinese: ChineseReading(
            pinyin: ["xué"],
            simplified: "学",
            traditional: "學",
            meaningsSimplified: ["study", "learn"],
            meaningsTraditional: ["study", "learn"]
        ),
        strokeCount: 8,
        radical: "子",
        frequencyRank: 67,
        falseFriendId: nil
    )

    return SearchResultRow(character: character)
        .previewLayout(.sizeThatFits)
}

#Preview("False Friend") {
    let character = Character(
        character: "走",
        japanese: JapaneseReading(
            onyomi: ["ソウ"],
            kunyomi: ["はし.る"],
            meanings: ["run"],
            jlptLevel: 5
        ),
        chinese: ChineseReading(
            pinyin: ["zǒu"],
            simplified: "走",
            traditional: "走",
            meaningsSimplified: ["walk", "go"],
            meaningsTraditional: ["walk", "go"]
        ),
        strokeCount: 7,
        radical: "走",
        frequencyRank: 234,
        falseFriendId: "false_friend_1"
    )

    return SearchResultRow(character: character)
        .previewLayout(.sizeThatFits)
}

#Preview("Multiple Rows") {
    let characters = [
        Character(
            character: "学",
            japanese: JapaneseReading(
                onyomi: ["ガク"],
                kunyomi: ["まな.ぶ"],
                meanings: ["study", "learning"],
                jlptLevel: 5
            ),
            chinese: ChineseReading(
                pinyin: ["xué"],
                simplified: "学",
                traditional: "學",
                meaningsSimplified: ["study"],
                meaningsTraditional: ["study"]
            ),
            strokeCount: 8,
            radical: "子",
            frequencyRank: 67,
            falseFriendId: nil
        ),
        Character(
            character: "走",
            japanese: JapaneseReading(
                onyomi: ["ソウ"],
                kunyomi: ["はし.る"],
                meanings: ["run"],
                jlptLevel: 5
            ),
            chinese: ChineseReading(
                pinyin: ["zǒu"],
                simplified: "走",
                traditional: "走",
                meaningsSimplified: ["walk"],
                meaningsTraditional: ["walk"]
            ),
            strokeCount: 7,
            radical: "走",
            frequencyRank: 234,
            falseFriendId: "false_friend_1"
        )
    ]

    return List(characters) { char in
        SearchResultRow(character: char)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}
