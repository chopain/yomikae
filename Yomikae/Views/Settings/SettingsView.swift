import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = UserSettings.shared
    private let historyService = HistoryService.shared
    @State private var showingClearHistoryAlert = false
    @State private var historyCleared = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Chinese Reading System

                Section {
                    Picker("Reading System", selection: $settings.chineseSystem) {
                        ForEach(ChineseSystem.allCases, id: \.self) { system in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(system.displayName)
                                    .font(.body)
                                Text(system.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(system)
                        }
                    }
                    .pickerStyle(.inline)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text("Current: \(settings.chineseSystem.displayName)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Text(regionInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Divider()
                            .padding(.vertical, 4)

                        Label {
                            Text("Some false friends only affect Simplified Chinese readers. We'll highlight warnings relevant to your reading system.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Chinese Reading System")
                } footer: {
                    Text("This setting affects which false friend warnings you'll see")
                        .font(.caption)
                }

                // MARK: - Display

                Section {
                    Picker("Font Size", selection: $settings.fontSize) {
                        ForEach(FontSize.allCases, id: \.self) { size in
                            HStack {
                                Text(size.displayName)
                                Spacer()
                                Text("Aa")
                                    .font(.system(size: 16 * size.scale))
                            }
                            .tag(size)
                        }
                    }
                    .pickerStyle(.inline)

                    HStack {
                        Text("Preview")
                            .foregroundColor(.secondary)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("漢字")
                                .font(.system(size: 24 * settings.fontSize.scale))
                            Text("Character preview")
                                .font(.system(size: 14 * settings.fontSize.scale))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Display")
                } footer: {
                    Text("Adjust text size throughout the app")
                        .font(.caption)
                }

                // MARK: - Speech

                Section {
                    Picker("Speech Rate", selection: $settings.speechRate) {
                        ForEach(SpeechRate.allCases, id: \.self) { rate in
                            Text(rate.displayName).tag(rate)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button {
                        SpeechService.shared.speakJapanese("漢字")
                    } label: {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                            Text("Test Speech")
                        }
                    }
                } header: {
                    Text("Speech")
                } footer: {
                    Text("Adjust the speed of text-to-speech pronunciation")
                        .font(.caption)
                }

                // MARK: - History

                Section {
                    Picker("Recent Items", selection: $settings.recentItemsCount) {
                        Text("5 items").tag(5)
                        Text("10 items").tag(10)
                        Text("20 items").tag(20)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Search History")
                                .font(.body)
                            Text("\(historyService.count) items stored")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: {
                            showingClearHistoryAlert = true
                        }) {
                            Text("Clear")
                                .foregroundColor(.red)
                        }
                        .disabled(historyService.count == 0)
                    }
                } header: {
                    Text("History")
                } footer: {
                    if historyCleared {
                        Label("History cleared", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                .alert("Clear Search History?", isPresented: $showingClearHistoryAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        historyService.clearHistory()
                        historyCleared = true

                        // Reset the confirmation message after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            historyCleared = false
                        }
                    }
                } message: {
                    Text("This will permanently delete all \(historyService.count) items from your search history.")
                }

                // MARK: - About

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://yomikae.app/privacy")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://yomikae.app/support")!) {
                        HStack {
                            Label("Support & Feedback", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: CreditsView()) {
                        Label("Credits & Acknowledgments", systemImage: "heart.fill")
                    }

                    NavigationLink(destination: FalseFriendCategoriesView()) {
                        Label("False Friend Categories", systemImage: "info.circle.fill")
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Computed Properties

    private var regionInfo: String {
        switch settings.chineseSystem {
        case .simplified:
            return "Mainland China, Singapore, Malaysia"
        case .traditional:
            return "Taiwan, Hong Kong, Macau"
        case .both:
            return "You'll see warnings for both systems"
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Credits View

struct CreditsView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yomikae")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("読み替え")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Learn kanji using the Chinese you already know")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.vertical, 8)
            }

            Section {
                CreditRow(
                    title: "Character Data",
                    description: "KANJIDIC2, CC-CEDICT, and Unihan database"
                )

                CreditRow(
                    title: "Frequency Rankings",
                    description: "Based on Japanese and Chinese corpus analysis"
                )

                CreditRow(
                    title: "JLPT Levels",
                    description: "Japanese Language Proficiency Test data"
                )
            } header: {
                Text("Data Sources")
            }

            Section {
                CreditRow(
                    title: "SwiftUI",
                    description: "Apple's declarative UI framework"
                )

                CreditRow(
                    title: "GRDB",
                    description: "SQLite database toolkit for Swift"
                )

                CreditRow(
                    title: "Combine",
                    description: "Apple's reactive programming framework"
                )
            } header: {
                Text("Technologies")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Special Thanks")
                        .font(.headline)

                    Text("To all Chinese learners of Japanese and Japanese learners of Chinese who inspired this app.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreditRow: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - False Friend Categories View

struct FalseFriendCategoriesView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Understanding False Friends")
                        .font(.headline)

                    Text("Characters that look the same but have different meanings in Japanese and Chinese. Learn these differences to avoid confusion.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }

            Section {
                CategoryRow(
                    icon: "🔄",
                    title: "Meaning Shift",
                    description: "The character's meaning evolved differently in Japanese and Chinese over time.",
                    example: "娘 = daughter (JP) vs. mother (CN)",
                    severity: .critical
                )

                CategoryRow(
                    icon: "✂️",
                    title: "Simplification Merge",
                    description: "Multiple Traditional characters were merged into one Simplified character, but Japanese kept them distinct.",
                    example: "后 merged from 后 (queen) and 後 (after)",
                    severity: .critical,
                    note: "Only affects Simplified Chinese readers"
                )

                CategoryRow(
                    icon: "📚",
                    title: "Modern Term",
                    description: "A modern word or concept that exists in both languages but with different meanings.",
                    example: "新聞 = newspaper (JP) vs. news (CN)",
                    severity: .important
                )

                CategoryRow(
                    icon: "🎭",
                    title: "Usage Context",
                    description: "The character can have similar meanings but is used in very different contexts or carries different connotations.",
                    example: "老婆 = wife (CN) vs. old woman (JP)",
                    severity: .subtle
                )
            } header: {
                Text("Categories")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    SeverityInfoRow(severity: .critical, description: "Completely different meanings - high risk of confusion")
                    SeverityInfoRow(severity: .important, description: "Significantly different - may cause misunderstandings")
                    SeverityInfoRow(severity: .subtle, description: "Nuanced differences - context matters")
                }
                .padding(.vertical, 8)
            } header: {
                Text("Severity Levels")
            }
        }
        .navigationTitle("False Friend Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryRow: View {
    let icon: String
    let title: String
    let description: String
    let example: String
    let severity: Severity
    let note: String?

    init(icon: String, title: String, description: String, example: String, severity: Severity, note: String? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.example = example
        self.severity = severity
        self.note = note
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(severity.color)
                            .frame(width: 8, height: 8)
                        Text(severity.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "text.quote")
                    .font(.caption)
                    .foregroundColor(.blue)

                Text(example)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)

            if let note = note {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SeverityInfoRow: View {
    let severity: Severity
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(severity.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(severity.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview("Settings View") {
    SettingsView()
}

#Preview("Credits View") {
    NavigationStack {
        CreditsView()
    }
}

#Preview("Categories View") {
    NavigationStack {
        FalseFriendCategoriesView()
    }
}
