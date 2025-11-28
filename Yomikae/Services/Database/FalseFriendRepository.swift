import Foundation

/// Repository for accessing false friend data from the database
class FalseFriendRepository {
    private let dbManager = DatabaseManager.shared

    // MARK: - Public Methods

    /// Get all false friends from the database
    /// - Returns: Array of all false friends, sorted by character
    func getAll() async -> [FalseFriend] {
        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getAllFalseFriends()
        }.value
    }

    /// Get false friends filtered by severity level
    /// - Parameter severity: The severity level to filter by
    /// - Returns: Array of false friends with the specified severity
    func getBySeverity(_ severity: FalseFriend.Severity) async -> [FalseFriend] {
        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getAllFalseFriends(severity: severity)
        }.value
    }

    /// Get a specific false friend by its ID
    /// - Parameter id: The unique identifier of the false friend
    /// - Returns: The false friend if found, nil otherwise
    func get(id: String) async -> FalseFriend? {
        guard !id.isEmpty else {
            return nil
        }

        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getFalseFriend(id: id)
        }.value
    }

    /// Get the false friend entry for a specific character
    /// - Parameter char: The character to look up
    /// - Returns: The false friend if found, nil otherwise
    func getForCharacter(_ char: String) async -> FalseFriend? {
        guard !char.isEmpty else {
            return nil
        }

        return await Task.detached(priority: .userInitiated) {
            self.dbManager.getFalseFriendForCharacter(char)
        }.value
    }

    /// Get false friends filtered by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of false friends with the specified category
    func getByCategory(_ category: FalseFriend.Category) async -> [FalseFriend] {
        return await Task.detached(priority: .userInitiated) {
            let allFalseFriends = self.dbManager.getAllFalseFriends()
            return allFalseFriends.filter { $0.category == category }
        }.value
    }

    /// Get false friends relevant to a specific Chinese system
    /// - Parameter system: The Chinese system (simplified/traditional/both)
    /// - Returns: Array of false friends relevant to the specified system
    func getRelevantForSystem(_ system: ChineseSystem) async -> [FalseFriend] {
        return await Task.detached(priority: .userInitiated) {
            let allFalseFriends = self.dbManager.getAllFalseFriends()
            return allFalseFriends.filter { $0.isRelevant(for: system) }
        }.value
    }

    /// Get false friends by multiple criteria
    /// - Parameters:
    ///   - severity: Optional severity filter
    ///   - category: Optional category filter
    ///   - system: Optional Chinese system filter
    /// - Returns: Array of false friends matching all specified criteria
    func getFiltered(
        severity: FalseFriend.Severity? = nil,
        category: FalseFriend.Category? = nil,
        system: ChineseSystem? = nil
    ) async -> [FalseFriend] {
        return await Task.detached(priority: .userInitiated) {
            var falseFriends = self.dbManager.getAllFalseFriends(severity: severity)

            if let category = category {
                falseFriends = falseFriends.filter { $0.category == category }
            }

            if let system = system {
                falseFriends = falseFriends.filter { $0.isRelevant(for: system) }
            }

            return falseFriends
        }.value
    }
}
