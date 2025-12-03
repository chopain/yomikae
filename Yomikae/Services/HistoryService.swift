import Foundation

/// Service for managing character lookup history
class HistoryService {
    // MARK: - Singleton

    static let shared = HistoryService()

    // MARK: - Constants

    private let maxHistoryCount = 20
    private let historyKey = "character_lookup_history"

    // MARK: - Private Properties

    private var history: [Character] = []

    // MARK: - Initialization

    private init() {
        loadHistory()
    }

    // MARK: - Public Methods

    /// Add a character to lookup history
    /// - Parameter character: The character to add
    func addToHistory(_ character: Character) {
        // Remove if already exists (to avoid duplicates)
        history.removeAll { $0.id == character.id }

        // Insert at beginning
        history.insert(character, at: 0)

        // Limit to max count
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        // Persist to UserDefaults
        saveHistory()
    }

    /// Get all character lookup history
    /// - Returns: Array of characters in reverse chronological order
    func getHistory() -> [Character] {
        return history
    }

    /// Clear all lookup history
    func clearHistory() {
        history = []
        saveHistory()
    }

    /// Remove a specific character from history
    /// - Parameter character: The character to remove
    func removeFromHistory(_ character: Character) {
        history.removeAll { $0.id == character.id }
        saveHistory()
    }

    /// Get recent history limited to a specific count
    /// - Parameter limit: Maximum number of items to return (default: 10)
    /// - Returns: Array of recent characters
    func getRecentHistory(limit: Int = 10) -> [Character] {
        return Array(history.prefix(limit))
    }

    /// Check if a character is in history
    /// - Parameter character: The character to check
    /// - Returns: True if character is in history
    func isInHistory(_ character: Character) -> Bool {
        return history.contains { $0.id == character.id }
    }

    /// Get history count
    var count: Int {
        return history.count
    }

    // MARK: - Private Methods

    /// Load history from UserDefaults
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            history = []
            return
        }

        do {
            let decoder = JSONDecoder()
            history = try decoder.decode([Character].self, from: data)

            // Ensure history doesn't exceed max count (in case it was changed)
            if history.count > maxHistoryCount {
                history = Array(history.prefix(maxHistoryCount))
                saveHistory()
            }
        } catch {
            print("Failed to decode history: \(error)")
            history = []
        }
    }

    /// Save history to UserDefaults
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to encode history: \(error)")
        }
    }
}

// MARK: - History Statistics

extension HistoryService {
    /// Get statistics about lookup history
    struct HistoryStats {
        let totalLookups: Int
        let uniqueCharacters: Int
        let mostLookedUpCharacter: Character?
        let falseFriendsLookedUp: Int
        let jlptDistribution: [Int: Int] // JLPT level -> count
    }

    /// Calculate history statistics
    /// - Returns: HistoryStats object with various metrics
    func getStatistics() -> HistoryStats {
        let totalLookups = history.count
        let uniqueCharacters = Set(history.map { $0.id }).count

        // Count false friends
        let falseFriendsCount = history.filter { $0.isFalseFriend }.count

        // Calculate JLPT distribution
        var jlptDistribution: [Int: Int] = [:]
        for character in history {
            if let jlptLevel = character.japanese?.jlptLevel {
                jlptDistribution[jlptLevel, default: 0] += 1
            }
        }

        // Find most looked up (this is simplified - in a real app you'd track lookup counts)
        let mostLookedUp = history.first

        return HistoryStats(
            totalLookups: totalLookups,
            uniqueCharacters: uniqueCharacters,
            mostLookedUpCharacter: mostLookedUp,
            falseFriendsLookedUp: falseFriendsCount,
            jlptDistribution: jlptDistribution
        )
    }

    /// Get characters filtered by criteria
    /// - Parameters:
    ///   - falseFriendsOnly: Only return false friends (default: false)
    ///   - jlptLevel: Only return characters at this JLPT level (optional)
    /// - Returns: Filtered array of characters
    func getFilteredHistory(
        falseFriendsOnly: Bool = false,
        jlptLevel: Int? = nil
    ) -> [Character] {
        var filtered = history

        if falseFriendsOnly {
            filtered = filtered.filter { $0.isFalseFriend }
        }

        if let jlptLevel = jlptLevel {
            filtered = filtered.filter { $0.japanese?.jlptLevel == jlptLevel }
        }

        return filtered
    }
}

// MARK: - Export/Import

extension HistoryService {
    /// Export history as JSON data
    /// - Returns: JSON data or nil if encoding fails
    func exportHistory() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(history)
        } catch {
            print("Failed to export history: \(error)")
            return nil
        }
    }

    /// Import history from JSON data
    /// - Parameter data: JSON data containing character array
    /// - Returns: True if import successful
    @discardableResult
    func importHistory(_ data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode([Character].self, from: data)

            // Merge with existing history, removing duplicates
            for character in imported.reversed() {
                addToHistory(character)
            }

            return true
        } catch {
            print("Failed to import history: \(error)")
            return false
        }
    }
}
