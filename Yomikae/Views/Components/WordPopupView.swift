import SwiftUI

/// A popup view that displays details about a tapped word
struct WordPopupView: View {
    let word: String
    let language: TappableTextLanguage
    let onViewDetails: ((Character) -> Void)?
    let onDismiss: () -> Void

    @State private var characters: [Character] = []
    @State private var falseFriends: [String: FalseFriend] = [:]
    @State private var isLoading = true

    private let databaseManager = DatabaseManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if characters.isEmpty {
                    notFoundView
                } else {
                    contentView
                }
            }
            .navigationTitle(word)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            await loadData()
        }
    }

    // MARK: - Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Looking up characters...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "character.magnify")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No data found")
                .font(.headline)

            Text("This word is not in our database yet.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Large word display
                HStack {
                    Spacer()
                    Text(word)
                        .font(.system(size: 48, weight: .regular))
                        .foregroundColor(hasFalseFriend ? .red : .primary)
                    Spacer()
                }
                .padding(.vertical, 8)

                // False friend warning banner
                if hasFalseFriend {
                    falseFriendBanner
                }

                // Character details
                ForEach(characters, id: \.id) { character in
                    characterCard(for: character)
                }

                // View full details button
                if let firstCharacter = characters.first, onViewDetails != nil {
                    Button {
                        onViewDetails?(firstCharacter)
                    } label: {
                        HStack {
                            Text("View Full Details")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }

    private var falseFriendBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("False Friend")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("This word has different meanings in Japanese and Chinese")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red)
        )
    }

    private func characterCard(for character: Character) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Character header
            HStack {
                Text(character.character)
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if let falseFriend = falseFriends[character.character] {
                    Text(falseFriend.severity.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(falseFriend.severity.color.opacity(0.2))
                        .foregroundColor(falseFriend.severity.color)
                        .cornerRadius(6)
                }
            }

            // Japanese reading
            if let japanese = character.japanese, language == .japanese {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("🇯🇵")
                        Text("Japanese")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }

                    if !japanese.kunyomi.isEmpty {
                        HStack(spacing: 8) {
                            Text("Kun:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)
                            Text(japanese.kunyomi.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }

                    if !japanese.onyomi.isEmpty {
                        HStack(spacing: 8) {
                            Text("On:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)
                            Text(japanese.onyomi.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }

                    if !japanese.meanings.isEmpty {
                        Text(japanese.meanings.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // Chinese reading
            if let chinese = character.chinese, language == .chinese {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("🇨🇳")
                        Text("Chinese")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }

                    if !chinese.pinyin.isEmpty {
                        HStack(spacing: 8) {
                            Text("Pinyin:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(chinese.pinyin.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }

                    let meanings = chinese.meaningsSimplified + chinese.meaningsTraditional
                    if !meanings.isEmpty {
                        Text(Array(Set(meanings)).joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            // Show both if character has both and one is a false friend
            if let falseFriend = falseFriends[character.character] {
                if let japanese = character.japanese, language == .chinese {
                    // Show Japanese meaning for comparison when viewing Chinese
                    comparisonCard(
                        flag: "🇯🇵",
                        label: "In Japanese",
                        meaning: japanese.meanings.joined(separator: ", "),
                        color: .blue
                    )
                }

                if let chinese = character.chinese, language == .japanese {
                    // Show Chinese meaning for comparison when viewing Japanese
                    let meanings = chinese.meaningsSimplified + chinese.meaningsTraditional
                    comparisonCard(
                        flag: "🇨🇳",
                        label: "In Chinese",
                        meaning: Array(Set(meanings)).joined(separator: ", "),
                        color: .red
                    )
                }

                // Show explanation if available
                if !falseFriend.explanation.isEmpty {
                    Text(falseFriend.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func comparisonCard(flag: String, label: String, meaning: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(flag)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(meaning)
                    .font(.subheadline)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(6)
    }

    // MARK: - Computed Properties

    private var hasFalseFriend: Bool {
        !falseFriends.isEmpty
    }

    // MARK: - Data Loading

    private func loadData() async {
        var loadedCharacters: [Character] = []
        var loadedFalseFriends: [String: FalseFriend] = [:]

        // Look up each character in the word
        for char: Swift.Character in word {
            let charString = String(char)
            if char.isKanji {
                if let character = databaseManager.getCharacter(char: charString) {
                    loadedCharacters.append(character)

                    // Check if it's a false friend
                    if let falseFriend = databaseManager.getFalseFriendForCharacter(charString) {
                        loadedFalseFriends[charString] = falseFriend
                    }
                }
            }
        }

        await MainActor.run {
            self.characters = loadedCharacters
            self.falseFriends = loadedFalseFriends
            self.isLoading = false
        }
    }
}

// MARK: - Preview

#Preview("With Data") {
    WordPopupView(
        word: "手紙",
        language: .japanese,
        onViewDetails: { _ in },
        onDismiss: {}
    )
}

#Preview("False Friend") {
    WordPopupView(
        word: "走",
        language: .japanese,
        onViewDetails: { _ in },
        onDismiss: {}
    )
}

#Preview("Not Found") {
    WordPopupView(
        word: "テスト",
        language: .japanese,
        onViewDetails: nil,
        onDismiss: {}
    )
}
