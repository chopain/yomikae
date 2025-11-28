import SwiftUI

struct CharacterDetailView: View {
    let character: Character

    @State private var falseFriend: FalseFriend?
    @State private var isLoadingFalseFriend = false
    @State private var showShareSheet = false

    private let falseFriendRepository = FalseFriendRepository()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Character Card
                CharacterCard(
                    character: character,
                    falseFriend: falseFriend,
                    onFalseFriendTap: {
                        // Scroll to false friend explanation if needed
                    }
                )

                // False Friend Detailed Explanation
                if let falseFriend = falseFriend {
                    falseFriendExplanationSection(falseFriend)
                }

                // Related Characters Section (Future)
                relatedCharactersSection

                // Study Actions Section (Future)
                studyActionsSection
            }
            .padding()
        }
        .navigationTitle(character.character)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
        .task {
            await loadFalseFriend()
        }
    }

    // MARK: - False Friend Explanation Section

    @ViewBuilder
    private func falseFriendExplanationSection(_ falseFriend: FalseFriend) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(falseFriend.severity.color)

                Text("False Friend Details")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            // Explanation
            VStack(alignment: .leading, spacing: 12) {
                Text("Why This Is Confusing")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(falseFriend.explanation)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )

            // Meaning Comparison
            meaningComparisonView(falseFriend)

            // Examples (if available)
            if !falseFriend.examples.isEmpty {
                examplesView(falseFriend.examples)
            }

            // Traditional Note (if applicable)
            if let traditionalNote = falseFriend.traditionalNote {
                traditionalNoteView(traditionalNote)
            }

            // Merged From (if applicable)
            if let mergedFrom = falseFriend.mergedFrom, !mergedFrom.isEmpty {
                mergedFromView(mergedFrom)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    private func meaningComparisonView(_ falseFriend: FalseFriend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meaning Comparison")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(alignment: .top, spacing: 16) {
                // Japanese Meanings
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("🇯🇵")
                            .font(.caption)
                        Text("Japanese")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    ForEach(falseFriend.jpMeanings, id: \.self) { meaning in
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(.secondary)
                            Text(meaning)
                                .font(.callout)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Chinese Meanings
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("🇨🇳")
                            .font(.caption)
                        Text("Chinese")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    ForEach(falseFriend.cnMeaningsSimplified, id: \.self) { meaning in
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(.secondary)
                            Text(meaning)
                                .font(.callout)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(falseFriend.severity.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(falseFriend.severity.color.opacity(0.3), lineWidth: 1)
        )
    }

    private func examplesView(_ examples: [Example]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Examples")
                .font(.headline)
                .foregroundColor(.secondary)

            ForEach(Array(examples.enumerated()), id: \.offset) { index, example in
                VStack(alignment: .leading, spacing: 8) {
                    // Japanese example
                    HStack(alignment: .top) {
                        Text("🇯🇵")
                            .font(.caption)
                        Text(example.japanese)
                            .font(.body)
                    }

                    // Chinese example
                    HStack(alignment: .top) {
                        Text("🇨🇳")
                            .font(.caption)
                        Text(example.chineseSimplified)
                            .font(.body)
                    }

                    // Translation
                    Text(example.translation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }

    private func traditionalNoteView(_ note: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Traditional Chinese Note")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(note)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }

    private func mergedFromView(_ mergedFrom: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.merge")
                    .foregroundColor(.orange)
                    .font(.caption)

                Text("Merged Characters")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("This simplified character merged these traditional characters:")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(mergedFrom, id: \.self) { char in
                    Text(char)
                        .font(.title)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Related Characters Section (Future)

    private var relatedCharactersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.blue)

                Text("Related Characters")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            // Placeholder
            VStack(spacing: 12) {
                Image(systemName: "character.book.closed")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("We'll show characters with similar meanings, components, or radicals here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Study Actions Section (Future)

    private var studyActionsSection: some View {
        VStack(spacing: 12) {
            // Add to Favorites Button (Placeholder)
            Button(action: {
                // TODO: Implement favorites functionality
            }) {
                HStack {
                    Image(systemName: "heart")
                        .font(.body)

                    Text("Add to Favorites")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)

            // Add to Study List Button (Placeholder)
            Button(action: {
                // TODO: Implement study list functionality
            }) {
                HStack {
                    Image(systemName: "book")
                        .font(.body)

                    Text("Add to Study List")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Data Loading

    private func loadFalseFriend() async {
        guard let falseFriendId = character.falseFriendId else { return }

        isLoadingFalseFriend = true
        falseFriend = await falseFriendRepository.get(id: falseFriendId)
        isLoadingFalseFriend = false
    }

    // MARK: - Share Text

    private var shareText: String {
        var text = "Character: \(character.character)\n\n"

        if let japanese = character.japanese {
            text += "Japanese:\n"
            if !japanese.onyomi.isEmpty {
                text += "On'yomi: \(japanese.onyomi.joined(separator: ", "))\n"
            }
            if !japanese.kunyomi.isEmpty {
                text += "Kun'yomi: \(japanese.kunyomi.joined(separator: ", "))\n"
            }
            if !japanese.meanings.isEmpty {
                text += "Meanings: \(japanese.meanings.joined(separator: ", "))\n"
            }
            text += "\n"
        }

        if let chinese = character.chinese {
            text += "Chinese:\n"
            text += "Pinyin: \(chinese.pinyin.joined(separator: ", "))\n"
            if !chinese.meaningsSimplified.isEmpty {
                text += "Meanings: \(chinese.meaningsSimplified.joined(separator: ", "))\n"
            }
            text += "\n"
        }

        if character.isFalseFriend {
            text += "⚠️ This is a False Friend - different meanings in Japanese and Chinese!\n"
        }

        text += "\nShared from Yomikae (読み替え)"

        return text
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Standard Character") {
    NavigationStack {
        CharacterDetailView(
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
            )
        )
    }
}

#Preview("False Friend") {
    NavigationStack {
        CharacterDetailView(
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
            )
        )
    }
}
