import SwiftUI

struct FalseFriendDetailView: View {
    let falseFriend: FalseFriend

    @ObservedObject private var settings = UserSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Character Display with Severity Banner
                characterSection

                // Merged Characters Section (for simplification merges)
                if falseFriend.category == .simplificationMerge {
                    mergedCharactersSection
                }

                // Japanese Section
                japaneseSection

                // Chinese Section
                chineseSection

                // Why Different? Section
                whyDifferentSection

                // Memory Tip Section (placeholder for future)
                memoryTipSection

                // Traditional Note (if exists)
                if let note = falseFriend.traditionalNote {
                    traditionalNoteSection(note)
                }

                // Affected System Info
                affectedSystemSection
            }
            .padding()
        }
        .navigationTitle("False Friend")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Character Section

    private var characterSection: some View {
        VStack(spacing: 16) {
            // Large character
            Text(falseFriend.character)
                .font(.system(size: characterFontSize, weight: .regular))
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(falseFriend.severity.color)

            // Severity Banner (without tap handler)
            FalseFriendBanner(falseFriend: falseFriend, onTap: nil)
        }
    }

    private var characterFontSize: CGFloat {
        let charCount = falseFriend.character.count
        if charCount == 1 {
            return 100
        } else if charCount == 2 {
            return 80
        } else if charCount == 3 {
            return 60
        } else {
            return 50
        }
    }

    // MARK: - Merged Characters Section

    private var mergedCharactersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.merge")
                    .foregroundColor(.orange)
                    .font(.title3)

                Text("Simplification Merge")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Text("In Simplified Chinese, this character was created by merging multiple Traditional characters:")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let mergedFrom = falseFriend.mergedFrom, !mergedFrom.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(mergedFrom.enumerated()), id: \.offset) { index, char in
                        HStack(spacing: 12) {
                            Text(char)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Traditional Character \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("Merged into Simplified: \(falseFriend.character)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                    }
                }
            }

            // Highlight Traditional = Japanese
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Insight")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Traditional Chinese often preserves the meaning that matches Japanese, while Simplified Chinese merged it with another character.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Japanese Section

    private var japaneseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Text("🇯🇵")
                    .font(.title2)

                Text("Japanese")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // Meanings
            VStack(alignment: .leading, spacing: 8) {
                Text("Meanings")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                ForEach(falseFriend.jpMeanings, id: \.self) { meaning in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)

                        Text(meaning)
                            .font(.body)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )

            // Examples
            if let example = falseFriend.examples.first {
                exampleCard(
                    title: "Example in Japanese",
                    text: example.japanese,
                    translation: example.translation,
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Chinese Section

    private var chineseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Text("🇨🇳")
                    .font(.title2)

                Text("Chinese")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // Simplified Meanings
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Simplified (简体)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    if falseFriend.affectedSystem == .simplifiedOnly {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                ForEach(falseFriend.cnMeaningsSimplified, id: \.self) { meaning in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)

                        Text(meaning)
                            .font(.body)

                        // Highlight if matches Japanese
                        if falseFriend.jpMeanings.contains(where: {
                            $0.localizedCaseInsensitiveContains(meaning) ||
                            meaning.localizedCaseInsensitiveContains($0)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )

            // Traditional Meanings (if different)
            if !falseFriend.cnMeaningsTraditional.isEmpty &&
               falseFriend.cnMeaningsTraditional != falseFriend.cnMeaningsSimplified {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Traditional (繁體)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(falseFriend.cnMeaningsTraditional, id: \.self) { meaning in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)

                            Text(meaning)
                                .font(.body)

                            // Highlight if matches Japanese
                            if falseFriend.jpMeanings.contains(where: {
                                $0.localizedCaseInsensitiveContains(meaning) ||
                                meaning.localizedCaseInsensitiveContains($0)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)

                                    Text("Matches JP")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }

                    // Highlight that Traditional often matches Japanese
                    if traditionalMatchesJapanese {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)

                            Text("Traditional Chinese preserves the Japanese meaning!")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }

            // Examples
            if let example = falseFriend.examples.first {
                exampleCard(
                    title: "Example in Chinese",
                    text: example.chineseSimplified,
                    translation: example.translation,
                    color: .red
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Why Different Section

    private var whyDifferentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(falseFriend.severity.color)
                    .font(.title3)

                Text("Why Are They Different?")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // Category
            HStack(spacing: 10) {
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(falseFriend.category.displayName)
                        .font(.headline)

                    Text(falseFriend.category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Explanation
            Text(falseFriend.explanation)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(falseFriend.severity.color.opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Memory Tip Section

    private var memoryTipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title3)

                Text("Memory Tip")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // Placeholder for future mnemonic content
            VStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("We'll add helpful memory techniques here to help you remember the difference.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Traditional Note Section

    private func traditionalNoteSection(_ note: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 6) {
                Text("Note for Traditional Chinese Readers")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(note)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }

    // MARK: - Affected System Section

    private var affectedSystemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.secondary)

                Text("Who This Affects")
                    .font(.headline)
            }

            HStack(spacing: 16) {
                // Affected system badge
                HStack(spacing: 6) {
                    Image(systemName: affectedSystemIcon)
                        .foregroundColor(.accentColor)

                    Text(falseFriend.affectedSystem.displayName)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)

                // User relevance
                if settings.chineseSystem != .both {
                    HStack(spacing: 6) {
                        Image(systemName: isRelevantToUser ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(isRelevantToUser ? .red : .green)

                        Text(isRelevantToUser ? "Affects you" : "Doesn't affect you")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }

            Text(falseFriend.affectedSystem.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Helper Views

    private func exampleCard(title: String, text: String, translation: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(text)
                .font(.body)
                .padding(.bottom, 4)

            HStack(spacing: 4) {
                Image(systemName: "quote.opening")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(translation)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Computed Properties

    private var categoryIcon: String {
        switch falseFriend.category {
        case .trueDivergence:
            return "arrow.triangle.branch"
        case .simplificationMerge:
            return "arrow.triangle.merge"
        case .japaneseCoinage:
            return "yensign.circle"
        case .scopeDifference:
            return "scope"
        }
    }

    private var affectedSystemIcon: String {
        switch falseFriend.affectedSystem {
        case .both:
            return "globe"
        case .simplifiedOnly:
            return "s.square"
        case .traditionalOnly:
            return "t.square"
        }
    }

    private var traditionalMatchesJapanese: Bool {
        guard !falseFriend.cnMeaningsTraditional.isEmpty else { return false }

        // Check if any Traditional meaning matches any Japanese meaning
        for tradMeaning in falseFriend.cnMeaningsTraditional {
            for jpMeaning in falseFriend.jpMeanings {
                if tradMeaning.localizedCaseInsensitiveContains(jpMeaning) ||
                   jpMeaning.localizedCaseInsensitiveContains(tradMeaning) {
                    return true
                }
            }
        }

        return false
    }

    private var isRelevantToUser: Bool {
        falseFriend.isRelevant(for: settings.chineseSystem)
    }
}

// MARK: - Previews

#Preview("True Divergence") {
    NavigationStack {
        FalseFriendDetailView(
            falseFriend: FalseFriend(
                id: "ff1",
                character: "走",
                jpReading: "はしる (hashiru)",
                jpMeanings: ["run", "to run"],
                cnPinyin: "zǒu",
                cnMeaningsSimplified: ["walk", "go", "leave"],
                cnMeaningsTraditional: ["walk", "go", "leave"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "The meanings of this character diverged completely over time. In Japanese, it retained the meaning 'to run', while in Chinese it evolved to mean 'to walk' or 'to go'. This is one of the most critical false friends as the meanings are almost opposite.",
                examples: [
                    Example(
                        japanese: "彼は速く走る",
                        chineseSimplified: "他走得很快",
                        chineseTraditional: "他走得很快",
                        translation: "JP: He runs fast / CN: He walks fast"
                    )
                ],
                traditionalNote: nil,
                mergedFrom: nil
            )
        )
    }
}

#Preview("Simplification Merge") {
    NavigationStack {
        FalseFriendDetailView(
            falseFriend: FalseFriend(
                id: "ff2",
                character: "后",
                jpReading: "こう (kō)",
                jpMeanings: ["empress", "queen"],
                cnPinyin: "hòu",
                cnMeaningsSimplified: ["after", "behind", "back", "later"],
                cnMeaningsTraditional: ["empress", "queen"],
                severity: .important,
                category: .simplificationMerge,
                affectedSystem: .simplifiedOnly,
                explanation: "In Simplified Chinese, 后 was created by merging two distinct Traditional characters: 後 (after/behind) and 后 (empress/queen). Japanese uses 后 only for 'empress', while Simplified Chinese uses it for both meanings, causing confusion.",
                examples: [
                    Example(
                        japanese: "皇后陛下",
                        chineseSimplified: "三天后",
                        chineseTraditional: "皇后陛下",
                        translation: "JP: Her Majesty the Empress / CN: Three days later"
                    )
                ],
                traditionalNote: "If you read Traditional Chinese, this is not a false friend for you! Traditional uses 後 for 'after' and 后 for 'empress', matching the Japanese meaning.",
                mergedFrom: ["後", "后"]
            )
        )
    }
    .onAppear {
        UserSettings.shared.chineseSystem = .traditional
    }
}
