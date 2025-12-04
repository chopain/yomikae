import Foundation
import Combine
import SwiftUI

@MainActor
class FalseFriendsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var falseFriends: [FalseFriend] = []
    @Published var selectedSeverity: Severity? = nil
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    // MARK: - Private Properties

    private let repository = FalseFriendRepository()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// Filtered results based on search text and selected severity
    var filteredResults: [FalseFriend] {
        var results = falseFriends

        // Filter by severity if selected
        if let severity = selectedSeverity {
            results = results.filter { $0.severity == severity }
        }

        // Filter by search text
        if !searchText.isEmpty {
            results = results.filter { falseFriend in
                // Search in character
                if falseFriend.character.contains(searchText) {
                    return true
                }

                // Search in Japanese meanings
                if falseFriend.jpMeanings.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) {
                    return true
                }

                // Search in Chinese meanings
                if falseFriend.cnMeaningsSimplified.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) {
                    return true
                }

                // Search in explanation
                if falseFriend.explanation.localizedCaseInsensitiveContains(searchText) {
                    return true
                }

                return false
            }
        }

        return results
    }

    // MARK: - Statistics Computed Properties

    var totalCount: Int {
        falseFriends.count
    }

    var criticalCount: Int {
        falseFriends.filter { $0.severity == .critical }.count
    }

    var importantCount: Int {
        falseFriends.filter { $0.severity == .important }.count
    }

    var subtleCount: Int {
        falseFriends.filter { $0.severity == .subtle }.count
    }

    /// Count for the currently selected severity filter
    var filteredCount: Int {
        filteredResults.count
    }

    /// Breakdown by category
    var categoryBreakdown: [(category: Category, count: Int)] {
        let categories = Category.allCases
        return categories.map { category in
            let count = falseFriends.filter { $0.category == category }.count
            return (category: category, count: count)
        }
    }

    /// Breakdown by affected system
    var affectedSystemBreakdown: [(system: AffectedSystem, count: Int)] {
        let systems = AffectedSystem.allCases
        return systems.map { system in
            let count = falseFriends.filter { $0.affectedSystem == system }.count
            return (system: system, count: count)
        }
    }

    // MARK: - Initialization

    init() {
        // Load false friends on initialization
        Task {
            await loadFalseFriends()
        }
    }

    // MARK: - Public Methods

    /// Load all false friends from the repository
    func loadFalseFriends() async {
        isLoading = true

        falseFriends = await repository.getAll()

        isLoading = false
    }

    /// Filter false friends by severity
    /// - Parameter severity: The severity to filter by, or nil to show all
    func filterBySeverity(_ severity: Severity?) {
        selectedSeverity = severity
    }

    /// Clear all filters
    func clearFilters() {
        selectedSeverity = nil
        searchText = ""
    }

    /// Get false friends for a specific category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of false friends in that category
    func getFalseFriends(for category: Category) -> [FalseFriend] {
        falseFriends.filter { $0.category == category }
    }

    /// Get false friends for a specific affected system
    /// - Parameter system: The affected system to filter by
    /// - Returns: Array of false friends affecting that system
    func getFalseFriends(for system: AffectedSystem) -> [FalseFriend] {
        falseFriends.filter { $0.affectedSystem == system }
    }

    /// Check if a false friend is relevant to the current user
    /// - Parameter falseFriend: The false friend to check
    /// - Returns: True if relevant to user's Chinese system preference
    func isRelevantToUser(_ falseFriend: FalseFriend) -> Bool {
        let settings = UserSettings.shared
        return falseFriend.isRelevant(for: settings.chineseSystem)
    }

    /// Get only false friends relevant to the current user
    var relevantFalseFriends: [FalseFriend] {
        let settings = UserSettings.shared
        return falseFriends.filter { $0.isRelevant(for: settings.chineseSystem) }
    }

    /// Count of false friends relevant to the user
    var relevantCount: Int {
        relevantFalseFriends.count
    }

    /// Refresh the false friends list
    func refresh() async {
        await loadFalseFriends()
    }
}

// MARK: - Preview Helper

extension FalseFriendsViewModel {
    static var preview: FalseFriendsViewModel {
        let viewModel = FalseFriendsViewModel()
        viewModel.falseFriends = [
            FalseFriend(
                id: "ff1",
                character: "走",
                jpReading: "はしる (hashiru)",
                jpMeanings: ["run"],
                cnPinyin: "zǒu",
                cnMeaningsSimplified: ["walk", "go"],
                cnMeaningsTraditional: ["walk", "go"],
                severity: .critical,
                category: .trueDivergence,
                affectedSystem: .both,
                explanation: "In Japanese, 走 means 'to run' while in Chinese it means 'to walk'.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            FalseFriend(
                id: "ff2",
                character: "勉",
                jpReading: "べん (ben)",
                jpMeanings: ["strive", "endeavor"],
                cnPinyin: "miǎn",
                cnMeaningsSimplified: ["reluctantly", "barely"],
                cnMeaningsTraditional: ["reluctantly", "barely"],
                severity: .important,
                category: .scopeDifference,
                affectedSystem: .both,
                explanation: "Different connotations in Japanese and Chinese.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            ),
            FalseFriend(
                id: "ff3",
                character: "后",
                jpReading: "こう (kō)",
                jpMeanings: ["empress", "queen"],
                cnPinyin: "hòu",
                cnMeaningsSimplified: ["after", "behind"],
                cnMeaningsTraditional: ["empress"],
                severity: .important,
                category: .simplificationMerge,
                affectedSystem: .simplifiedOnly,
                explanation: "Simplified Chinese merged two characters.",
                examples: [],
                traditionalNote: "Traditional readers see the correct character.",
                mergedFrom: ["後", "后"]
            ),
            FalseFriend(
                id: "ff4",
                character: "腺",
                jpReading: "せん (sen)",
                jpMeanings: ["gland"],
                cnPinyin: "xiàn",
                cnMeaningsSimplified: ["gland"],
                cnMeaningsTraditional: ["gland"],
                severity: .subtle,
                category: .japaneseCoinage,
                affectedSystem: .both,
                explanation: "Character created in Japan for anatomy.",
                examples: [],
                traditionalNote: nil,
                mergedFrom: nil
            )
        ]
        return viewModel
    }
}
