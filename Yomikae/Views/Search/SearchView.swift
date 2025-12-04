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
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
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
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                    EmptyStateView.noRecentSearches()
                        .padding(.top, 100)
                }
            }
        }
    }

    private var loadingView: some View {
        LoadingView(message: "Searching...")
    }

    private var emptyResultsView: some View {
        EmptyStateView.noSearchResults(query: viewModel.searchText) {
            viewModel.clearResults()
        }
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
