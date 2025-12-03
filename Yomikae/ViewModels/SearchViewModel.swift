import Foundation
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchText: String = ""
    @Published var results: [Character] = []
    @Published var isLoading: Bool = false
    @Published var recentSearches: [Character] = []

    // MARK: - Private Properties

    private let repository = CharacterRepository()
    private let historyService = HistoryService.shared
    private var cancellables = Set<AnyCancellable>()
    private let searchDebounceTime: TimeInterval = 0.3 // 300ms

    // MARK: - Initialization

    init() {
        setupSearchDebouncing()
        loadRecentSearches()
    }

    // MARK: - Private Methods

    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .seconds(searchDebounceTime), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                Task {
                    await self?.performSearch(query: searchQuery)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            isLoading = false
            return
        }

        isLoading = true

        // Search in the database - the repository already sorts by frequency
        let searchResults = await repository.search(query: query, limit: 50)

        // Additional sorting by frequency rank (lower rank = more frequent)
        let sortedResults = searchResults.sorted { char1, char2 in
            // If both have frequency ranks, compare them
            if let rank1 = char1.frequencyRank, let rank2 = char2.frequencyRank {
                return rank1 < rank2
            }
            // Characters with frequency rank come before those without
            if char1.frequencyRank != nil {
                return true
            }
            if char2.frequencyRank != nil {
                return false
            }
            // If neither has a rank, maintain current order
            return false
        }

        results = sortedResults
        isLoading = false
    }

    private func loadRecentSearches() {
        // Load recent searches from history service
        recentSearches = historyService.getRecentHistory(limit: 10)
    }

    // MARK: - Public Methods

    /// Save a character to recent search history
    /// - Parameter character: The character to save
    func saveToRecentSearches(_ character: Character) {
        // Add to history service (handles deduplication and persistence)
        historyService.addToHistory(character)

        // Reload recent searches to update UI
        loadRecentSearches()
    }

    /// Clear all search results
    func clearResults() {
        searchText = ""
        results = []
    }

    /// Clear recent search history
    func clearRecentSearches() {
        historyService.clearHistory()
        recentSearches = []
    }
}
