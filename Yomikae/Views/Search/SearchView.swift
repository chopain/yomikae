import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

                // Content
                searchContent
            }
            .navigationTitle("読み替え")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: NavigationDestination.falseFriends) {
                        Label("False Friends", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .characterDetail(let character):
                    CharacterDetailView(character: character)
                case .falseFriends:
                    FalseFriendsView()
                }
            }
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var searchContent: some View {
        if viewModel.searchText.isEmpty {
            // Show recent searches when no query
            recentSearchesView
        } else if viewModel.isLoading {
            // Show loading indicator
            loadingView
        } else if viewModel.results.isEmpty {
            // Show empty state
            emptyResultsView
        } else {
            // Show search results
            resultsListView
        }
    }

    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.recentSearches.isEmpty {
                    // Recent searches section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Button(action: {
                                viewModel.clearRecentSearches()
                            }) {
                                Text("Clear")
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        ForEach(viewModel.recentSearches) { character in
                            Button(action: {
                                navigationPath.append(NavigationDestination.characterDetail(character))
                            }) {
                                SearchResultRow(character: character)
                            }
                            .buttonStyle(.plain)

                            if character.id != viewModel.recentSearches.last?.id {
                                Divider()
                                    .padding(.leading, 102)
                            }
                        }
                    }
                } else {
                    // Empty state for recent searches
                    ContentUnavailableView(
                        "No Recent Searches",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Your recently searched characters will appear here")
                    )
                    .padding(.top, 100)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Searching...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyResultsView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("No characters found for '\(viewModel.searchText)'")
        )
    }

    private var resultsListView: some View {
        List {
            ForEach(viewModel.results) { character in
                Button(action: {
                    // Save to recent searches
                    viewModel.saveToRecentSearches(character)
                    // Navigate to detail
                    navigationPath.append(NavigationDestination.characterDetail(character))
                }) {
                    SearchResultRow(character: character)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Navigation Destinations

enum NavigationDestination: Hashable {
    case characterDetail(Character)
    case falseFriends
}

// MARK: - Placeholder Views

/// Placeholder for CharacterDetailView (to be implemented)
struct CharacterDetailView: View {
    let character: Character

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Large character display
                Text(character.character)
                    .font(.system(size: 120))
                    .frame(maxWidth: .infinity)
                    .padding()

                // Details sections
                VStack(alignment: .leading, spacing: 16) {
                    if let japanese = character.japanese {
                        DetailSection(title: "Japanese") {
                            if !japanese.onyomi.isEmpty {
                                DetailRow(label: "On'yomi", value: japanese.onyomi.joined(separator: ", "))
                            }
                            if !japanese.kunyomi.isEmpty {
                                DetailRow(label: "Kun'yomi", value: japanese.kunyomi.joined(separator: ", "))
                            }
                            if !japanese.meanings.isEmpty {
                                DetailRow(label: "Meanings", value: japanese.meanings.joined(separator: ", "))
                            }
                            if let jlpt = japanese.jlptLevel {
                                DetailRow(label: "JLPT Level", value: "N\(jlpt)")
                            }
                        }
                    }

                    if let chinese = character.chinese {
                        DetailSection(title: "Chinese") {
                            DetailRow(label: "Pinyin", value: chinese.pinyin.joined(separator: ", "))
                            if let simplified = chinese.simplified {
                                DetailRow(label: "Simplified", value: simplified)
                            }
                            if let traditional = chinese.traditional {
                                DetailRow(label: "Traditional", value: traditional)
                            }
                            if !chinese.meaningsSimplified.isEmpty {
                                DetailRow(label: "Meanings (Simplified)", value: chinese.meaningsSimplified.joined(separator: ", "))
                            }
                        }
                    }

                    DetailSection(title: "Metadata") {
                        if let strokeCount = character.strokeCount {
                            DetailRow(label: "Stroke Count", value: "\(strokeCount)")
                        }
                        if let radical = character.radical {
                            DetailRow(label: "Radical", value: radical)
                        }
                        if let rank = character.frequencyRank {
                            DetailRow(label: "Frequency Rank", value: "#\(rank)")
                        }
                    }

                    if character.isFalseFriend {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("This is a False Friend")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(character.character)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    SearchView()
}
