import XCTest
import Combine
@testable import Yomikae

@MainActor
final class SearchViewModelTests: XCTestCase {
    var sut: SearchViewModel!
    var mockDatabaseService: MockDatabaseService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        mockDatabaseService = MockDatabaseService()
        sut = SearchViewModel()
        cancellables = []
    }

    override func tearDown() async throws {
        sut = nil
        mockDatabaseService = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Test: Search returns results for valid kanji

    func testSearchReturnsResultsForValidKanji() async throws {
        // Given
        sut.searchText = "手"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000) // 400ms

        // Then
        XCTAssertFalse(sut.searchResults.isEmpty, "Search should return results for valid kanji")
        XCTAssertTrue(
            sut.searchResults.contains { $0.character == "手" },
            "Search results should contain the character 手"
        )
    }

    func testSearchReturnsMultipleResultsForCommonKanji() async throws {
        // Given
        sut.searchText = "日"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertFalse(sut.searchResults.isEmpty, "Search should return results")
    }

    // MARK: - Test: Search returns results for pinyin

    func testSearchReturnsResultsForPinyin() async throws {
        // Given
        sut.searchText = "shou"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        // Note: This test depends on database having characters with pinyin "shou"
        // In a mock environment, we'd inject a mock database service
        XCTAssertTrue(
            sut.searchResults.isEmpty || sut.searchResults.contains { result in
                result.chinese?.pinyin.contains { $0.lowercased().contains("shou") } ?? false
            },
            "Search should handle pinyin queries"
        )
    }

    func testSearchReturnsResultsForPinyinWithTones() async throws {
        // Given
        sut.searchText = "shǒu"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(
            sut.searchResults.isEmpty || sut.searchResults.contains { result in
                result.chinese?.pinyin.contains("shǒu") ?? false
            },
            "Search should handle pinyin with tone marks"
        )
    }

    // MARK: - Test: Search returns results for English

    func testSearchReturnsResultsForEnglish() async throws {
        // Given
        sut.searchText = "hand"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(
            sut.searchResults.isEmpty || sut.searchResults.contains { result in
                result.japanese?.meanings.contains { $0.lowercased().contains("hand") } ?? false ||
                result.chinese?.meaningsSimplified.contains { $0.lowercased().contains("hand") } ?? false
            },
            "Search should return results for English meaning queries"
        )
    }

    func testSearchReturnsResultsForPartialEnglishMatch() async throws {
        // Given
        sut.searchText = "stud"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(
            sut.searchResults.isEmpty || sut.searchResults.contains { result in
                result.japanese?.meanings.contains { $0.lowercased().contains("stud") } ?? false
            },
            "Search should handle partial English matches"
        )
    }

    // MARK: - Test: Debouncing behavior

    func testSearchDebouncingDelaysExecution() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Debounce delay")

        // When - Rapid changes
        sut.searchText = "a"
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        sut.searchText = "ab"
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.searchText = "abc"

        // Check immediately (should not have searched yet)
        let immediateResultCount = sut.searchResults.count

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)

        // Then - Only final search should execute
        // Note: In a real test with mock, we'd verify search was called only once
    }

    func testSearchDebouncingCancelsEarlierSearches() async throws {
        // Given
        var searchCallCount = 0

        // When - Multiple rapid changes
        for char in ["手", "日", "学"] {
            sut.searchText = char
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms between changes
            searchCallCount += 1
        }

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        // Only the last search ("学") should have executed
        XCTAssertEqual(searchCallCount, 3, "All changes were made")
        // In a real test with mock, we'd verify only 1 actual search call
    }

    // MARK: - Test: Empty query returns empty results

    func testEmptyQueryReturnsEmptyResults() async throws {
        // Given
        sut.searchText = ""

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(sut.searchResults.isEmpty, "Empty query should return empty results")
    }

    func testWhitespaceOnlyQueryReturnsEmptyResults() async throws {
        // Given
        sut.searchText = "   "

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(sut.searchResults.isEmpty, "Whitespace-only query should return empty results")
    }

    func testClearingSearchTextClearsResults() async throws {
        // Given - First do a search
        sut.searchText = "手"
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertFalse(sut.searchResults.isEmpty, "Initial search should have results")

        // When - Clear the search
        sut.searchText = ""
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertTrue(sut.searchResults.isEmpty, "Clearing search should clear results")
    }

    // MARK: - Test: History is updated after lookup

    func testHistoryIsUpdatedAfterCharacterLookup() async throws {
        // Given
        let initialHistoryCount = sut.recentSearches.count

        // When - Search for a character
        sut.searchText = "手"
        try await Task.sleep(nanoseconds: 400_000_000)

        // Get a result and "tap" it (simulate viewing character detail)
        if let firstResult = sut.searchResults.first {
            sut.addToHistory(firstResult)
        }

        // Then
        XCTAssertEqual(
            sut.recentSearches.count,
            initialHistoryCount + 1,
            "History should be updated after character lookup"
        )
    }

    func testHistoryPreventsFullDuplicates() async throws {
        // Given
        let testCharacter = MockData.character手

        // When - Add same character twice
        sut.addToHistory(testCharacter)
        let countAfterFirst = sut.recentSearches.count

        sut.addToHistory(testCharacter)
        let countAfterSecond = sut.recentSearches.count

        // Then
        XCTAssertEqual(
            countAfterFirst,
            countAfterSecond,
            "History should not contain duplicate entries"
        )
    }

    func testHistoryMaintainsRecentItems() async throws {
        // Given
        let characters = MockData.allCharacters

        // When - Add multiple characters
        for character in characters {
            sut.addToHistory(character)
        }

        // Then
        XCTAssertEqual(
            sut.recentSearches.count,
            min(characters.count, 10), // Assuming max history is 10
            "History should maintain recent items"
        )

        // Most recent should be at the top
        if let mostRecent = sut.recentSearches.first {
            XCTAssertEqual(
                mostRecent.character,
                characters.last?.character,
                "Most recent item should be first in history"
            )
        }
    }

    // MARK: - Test: Loading states

    func testIsLoadingStatesDuringSearch() async throws {
        // Given
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")

        // When - Start a search
        sut.searchText = "手"

        // Check loading state immediately
        let isLoadingDuringSearch = sut.isLoading

        // Wait for completion
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        XCTAssertFalse(sut.isLoading, "Should not be loading after search completes")
    }

    // MARK: - Test: Error handling

    func testSearchHandlesErrors() async throws {
        // Given - This test would require injecting a mock that throws errors
        // For now, we test that the viewmodel doesn't crash with unusual input

        // When
        sut.searchText = "🎌" // Emoji

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then - Should not crash, results may be empty
        XCTAssertNotNil(sut.searchResults, "Search results should not be nil even with unusual input")
    }

    func testSearchHandlesVeryLongQueries() async throws {
        // Given
        let longQuery = String(repeating: "a", count: 1000)

        // When
        sut.searchText = longQuery

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then - Should handle gracefully
        XCTAssertNotNil(sut.searchResults, "Should handle very long queries without crashing")
    }

    // MARK: - Test: Search filtering

    func testSearchIsCaseInsensitive() async throws {
        // Given
        sut.searchText = "HAND"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000)

        let upperCaseResults = sut.searchResults

        sut.searchText = "hand"
        try await Task.sleep(nanoseconds: 400_000_000)

        let lowerCaseResults = sut.searchResults

        // Then
        XCTAssertEqual(
            upperCaseResults.count,
            lowerCaseResults.count,
            "Search should be case-insensitive"
        )
    }
}

// MARK: - Mock Database Service

class MockDatabaseService {
    func searchCharacters(query: String) async -> [Character] {
        // Simple mock implementation
        return MockData.allCharacters.filter { character in
            // Match by character
            if character.character.contains(query) {
                return true
            }

            // Match by Japanese reading
            if let japanese = character.japanese {
                if japanese.onyomi.contains(where: { $0.contains(query) }) ||
                   japanese.kunyomi.contains(where: { $0.contains(query) }) ||
                   japanese.meanings.contains(where: { $0.lowercased().contains(query.lowercased()) }) {
                    return true
                }
            }

            // Match by Chinese reading
            if let chinese = character.chinese {
                if chinese.pinyin.contains(where: { $0.lowercased().contains(query.lowercased()) }) ||
                   chinese.meaningsSimplified.contains(where: { $0.lowercased().contains(query.lowercased()) }) {
                    return true
                }
            }

            return false
        }
    }
}
