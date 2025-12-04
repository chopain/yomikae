import SwiftUI

struct CharacterCard: View {
    let character: Character
    let falseFriend: FalseFriend?
    var onFalseFriendTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // False Friend Banner (if applicable)
            if let falseFriend = falseFriend {
                FalseFriendBanner(
                    falseFriend: falseFriend,
                    onTap: onFalseFriendTap
                )
            }

            // Large Character Display
            HStack {
                Spacer()
                Text(character.character)
                    .font(.system(size: 80, weight: .regular))
                    .foregroundColor(falseFriend != nil ? .red : .primary)
                Spacer()
            }
            .padding(.vertical, 8)

            // Japanese Reading Section
            if let japanese = character.japanese {
                Divider()

                ReadingSection(
                    flag: "🇯🇵",
                    language: "Japanese",
                    readings: buildJapaneseReadings(japanese),
                    meanings: japanese.meanings
                )
            }

            // Chinese Reading Section
            if let chinese = character.chinese {
                Divider()

                ReadingSection(
                    flag: "🇨🇳",
                    language: "Chinese",
                    readings: buildChineseReadings(chinese),
                    meanings: buildChineseMeanings(chinese)
                )
            }

            // Metadata Row
            if hasMetadata {
                Divider()

                HStack(spacing: 16) {
                    if let strokeCount = character.strokeCount {
                        MetadataItem(
                            icon: "pencil.line",
                            label: "Strokes",
                            value: "\(strokeCount)"
                        )
                    }

                    if let radical = character.radical {
                        MetadataItem(
                            icon: "book.closed",
                            label: "Radical",
                            value: radical
                        )
                    }

                    if let rank = character.frequencyRank {
                        MetadataItem(
                            icon: "chart.bar",
                            label: "Frequency",
                            value: "#\(rank)"
                        )
                    }

                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }

    // MARK: - Helper Methods

    private func buildJapaneseReadings(_ japanese: JapaneseReading) -> [(label: String, value: String)] {
        var readings: [(label: String, value: String)] = []

        if !japanese.onyomi.isEmpty {
            readings.append((
                label: "On'yomi",
                value: japanese.onyomi.joined(separator: "、")
            ))
        }

        if !japanese.kunyomi.isEmpty {
            readings.append((
                label: "Kun'yomi",
                value: japanese.kunyomi.joined(separator: "、")
            ))
        }

        if let jlptLevel = japanese.jlptLevel {
            readings.append((
                label: "JLPT",
                value: "N\(jlptLevel)"
            ))
        }

        return readings
    }

    private func buildChineseReadings(_ chinese: ChineseReading) -> [(label: String, value: String)] {
        var readings: [(label: String, value: String)] = []

        if !chinese.pinyin.isEmpty {
            readings.append((
                label: "Pinyin",
                value: chinese.pinyin.joined(separator: ", ")
            ))
        }

        if let simplified = chinese.simplified, simplified != character.character {
            readings.append((
                label: "Simplified",
                value: simplified
            ))
        }

        if let traditional = chinese.traditional, traditional != character.character {
            readings.append((
                label: "Traditional",
                value: traditional
            ))
        }

        return readings
    }

    private func buildChineseMeanings(_ chinese: ChineseReading) -> [String] {
        // Combine simplified and traditional meanings, removing duplicates
        let allMeanings = chinese.meaningsSimplified + chinese.meaningsTraditional
        return Array(Set(allMeanings)).sorted()
    }

    private var hasMetadata: Bool {
        character.strokeCount != nil ||
        character.radical != nil ||
        character.frequencyRank != nil
    }
}

// MARK: - Metadata Item

private struct MetadataItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Standard Character") {
    ScrollView {
        CharacterCard(
            character: Character(
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
                    meaningsSimplified: ["study", "learn", "school"],
                    meaningsTraditional: ["study", "learn", "school"]
                ),
                strokeCount: 8,
                radical: "子",
                frequencyRank: 67,
                falseFriendId: nil
            ),
            falseFriend: nil
        )
        .padding()
    }
}

#Preview("False Friend") {
    ScrollView {
        CharacterCard(
            character: Character(
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
                    meaningsSimplified: ["walk", "go", "leave"],
                    meaningsTraditional: ["walk", "go", "leave"]
                ),
                strokeCount: 7,
                radical: "走",
                frequencyRank: 234,
                falseFriendId: "ff_zou"
            ),
            falseFriend: FalseFriend(
                id: "ff_zou",
                character: "走",
                jpReading: "はしる (hashiru)",
                jpMeanings: ["run"],
                cnPinyin: "zǒu",
                cnMeaningsSimplified: ["walk", "go"],
                cnMeaningsTraditional: ["walk", "go"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "In Japanese, 走 means 'to run' while in Chinese it means 'to walk' or 'to go'.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            onFalseFriendTap: {
                print("False friend tapped")
            }
        )
        .padding()
    }
}

#Preview("Simplified-Only False Friend") {
    ScrollView {
        CharacterCard(
            character: Character(
                character: "后",
                japanese: JapaneseReading(
                    onyomi: ["コウ", "ゴ"],
                    kunyomi: ["きさき"],
                    meanings: ["empress", "queen"],
                    jlptLevel: 1
                ),
                chinese: ChineseReading(
                    pinyin: ["hòu"],
                    simplified: "后",
                    traditional: "後",
                    meaningsSimplified: ["after", "behind", "back"],
                    meaningsTraditional: ["empress", "queen"]
                ),
                strokeCount: 6,
                radical: "口",
                frequencyRank: 156,
                falseFriendId: "ff_hou"
            ),
            falseFriend: FalseFriend(
                id: "ff_hou",
                character: "后",
                jpReading: "こう (kō)",
                jpMeanings: ["empress", "queen"],
                cnPinyin: "hòu",
                cnMeaningsSimplified: ["after", "behind"],
                cnMeaningsTraditional: ["empress"],
                severity: .important,
                category: .simplificationMerge,
                affectedSystem: .simplifiedOnly,
                explanation: "Simplified Chinese merged 後 (after) and 后 (empress) into 后.",
                examples: [],
                traditionalNote: "Traditional readers see the correct character.",
                mergedFrom: ["後", "后"]
            ),
            onFalseFriendTap: nil
        )
        .padding()
    }
    .onAppear {
        UserSettings.shared.chineseSystem = .traditional
    }
}

#Preview("Minimal Character") {
    ScrollView {
        CharacterCard(
            character: Character(
                character: "的",
                japanese: JapaneseReading(
                    onyomi: ["テキ"],
                    kunyomi: ["まと"],
                    meanings: ["target", "mark"],
                    jlptLevel: 3
                ),
                chinese: ChineseReading(
                    pinyin: ["de", "dí", "dì"],
                    simplified: "的",
                    traditional: "的",
                    meaningsSimplified: ["of", "possessive particle"],
                    meaningsTraditional: ["of", "possessive particle"]
                ),
                strokeCount: nil,
                radical: nil,
                frequencyRank: nil,
                falseFriendId: nil
            ),
            falseFriend: nil
        )
        .padding()
    }
}

#Preview("Multiple Cards") {
    ScrollView {
        VStack(spacing: 16) {
            CharacterCard(
                character: Character(
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
                        meaningsSimplified: ["study", "learn"],
                        meaningsTraditional: ["study", "learn"]
                    ),
                    strokeCount: 8,
                    radical: "子",
                    frequencyRank: 67,
                    falseFriendId: nil
                ),
                falseFriend: nil
            )

            CharacterCard(
                character: Character(
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
                    falseFriendId: "ff_zou"
                ),
                falseFriend: FalseFriend(
                    id: "ff_zou",
                    character: "走",
                    jpReading: "はしる (hashiru)",
                    jpMeanings: ["run"],
                    cnPinyin: "zǒu",
                    cnMeaningsSimplified: ["walk"],
                    cnMeaningsTraditional: ["walk"],
                    severity: .critical,
                    category: .trueDivergence,
                    affectedSystem: .both,
                    explanation: "Different meanings.",
                    examples: [],
                    traditionalNote: nil,
                    mergedFrom: nil
                ),
                onFalseFriendTap: nil
            )
        }
        .padding()
    }
}
