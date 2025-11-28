import Foundation

/// Repository for accessing character data from the database
class CharacterRepository {
    private let dbManager = DatabaseManager.shared

    // MARK: - Public Methods

    /// Search for characters matching the query string
    /// - Parameters:
    ///   - query: The search query (matches character or radical)
    ///   - limit: Maximum number of results to return (default: 50)
    /// - Returns: Array of matching characters, sorted by frequency rank
    func search(query: String, limit: Int = 50) async -> [Character] {
        guard !query.isEmpty else {
            return []
        }

        return await Task.detached(priority: .userInitiated) {
            self.dbManager.searchCharacters(query: query, limit: limit)
        }.value
    }

    /// Get a specific character by its character value
    /// - Parameter character: The character to look up
    /// - Returns: The character if found, nil otherwise
    func get(character: String) async -> Character? {
        guard !character.isEmpty else {
            return nil
        }

        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getCharacter(char: character)
        }.value
    }

    /// Get recently accessed characters
    /// - Parameter limit: Maximum number of recent characters to return (default: 10)
    /// - Returns: Array of recently accessed characters
    func getRecent(limit: Int = 10) async -> [Character] {
        // Note: This will be implemented when we add user history tracking
        // For now, return the most common characters by frequency
        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getTopCharacters(limit: limit)
        }.value
    }

    /// Get all false friend characters
    /// - Returns: Array of characters that are false friends
    func getFalseFriends() async -> [Character] {
        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getFalseFriendCharacters()
        }.value
    }

    /// Get characters by JLPT level
    /// - Parameter level: JLPT level (1-5)
    /// - Returns: Array of characters at the specified JLPT level
    func getByJLPTLevel(_ level: Int) async -> [Character] {
        guard (1...5).contains(level) else {
            return []
        }

        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getCharactersByJLPTLevel(level)
        }.value
    }
}
