# Yomikae Testing Guide

## Overview

This guide covers all testing infrastructure for the Yomikae app, including unit tests, UI previews, and how to set up and run tests.

---

## Test Files Created

### 1. Mock Data (`YomikaeTests/Mocks/MockData.swift`)

Provides reusable mock data for all tests:

- **Characters**: 手, 日, 学 with full Japanese and Chinese readings
- **False Friends**: 勉強 (critical), 娘 (high), 大家 (moderate), 手紙 (low)
- **Search Results**: Pre-configured result sets
- **Helper Methods**: Easy access to test data

**Usage**:
```swift
let testCharacter = MockData.character手
let testFalseFriend = MockData.falseFriend勉強
let searchResults = MockData.allCharacters
```

### 2. SearchViewModel Tests (`YomikaeTests/ViewModels/SearchViewModelTests.swift`)

Comprehensive tests for search functionality:

#### Test Coverage:
- ✅ Search returns results for valid kanji
- ✅ Search returns results for pinyin (with and without tones)
- ✅ Search returns results for English meanings
- ✅ Search debouncing delays execution (300ms delay)
- ✅ Empty query returns empty results
- ✅ History is updated after lookup
- ✅ History prevents duplicates
- ✅ Loading states during search
- ✅ Error handling for unusual input
- ✅ Case-insensitive search

#### Example Test:
```swift
func testSearchReturnsResultsForValidKanji() async throws {
    // Given
    sut.searchText = "手"

    // Wait for debounce
    try await Task.sleep(nanoseconds: 400_000_000)

    // Then
    XCTAssertFalse(sut.searchResults.isEmpty)
    XCTAssertTrue(sut.searchResults.contains { $0.character == "手" })
}
```

### 3. Database Tests (`YomikaeTests/Database/DatabaseManagerTests.swift`)

Comprehensive database layer tests:

#### Test Coverage:
- ✅ Character insertion and retrieval
- ✅ Update existing characters
- ✅ Retrieve non-existent character returns nil
- ✅ False friend insertion and retrieval
- ✅ Get all false friends
- ✅ Search by character, reading, pinyin, meaning
- ✅ Filter false friends by severity (critical, high, moderate, low)
- ✅ Filter false friends by category
- ✅ Database schema version tracking
- ✅ Required tables exist
- ✅ Migration is idempotent
- ✅ Unicode character handling
- ✅ Transaction rollback on error
- ✅ Bulk insert performance
- ✅ Search performance

#### Example Test:
```swift
func testInsertAndRetrieveCharacter() throws {
    // Given
    let character = MockData.character手

    // When
    try sut.insertCharacter(character)
    let retrieved = try sut.getCharacter(character.character)

    // Then
    XCTAssertNotNil(retrieved)
    XCTAssertEqual(retrieved?.character, character.character)
}
```

### 4. SwiftUI Previews (`Yomikae/Views/Components/ComponentPreviews.swift`)

Complete preview suite for all UI components:

#### Previews Included:
- **SearchView**: Empty state, with results
- **CharacterDetailView**: Normal character, false friend, minimal data
- **FalseFriendBanner**: All severity levels (critical, high, moderate, low)
- **FalseFriendDetailView**: Full data, multiple examples
- **SearchBar**: Empty, with text
- **ReadingSection**: Japanese and Chinese readings
- **LoadingView**: Light and dark mode
- **EmptyStateView**: No results, no history
- **FalseFriendsListView**: With data

#### Example Preview:
```swift
#Preview("CharacterDetailView - False Friend") {
    CharacterDetailView(character: PreviewData.characterWithFalseFriend)
}

#Preview("FalseFriendBanner - Critical") {
    FalseFriendBanner(severity: .critical)
        .padding()
}
```

---

## Setting Up Tests in Xcode

### Step 1: Create Test Target

The test files are created but need to be added to a test target:

1. **Open Xcode**
2. **Select the project** in the navigator (Yomikae)
3. **File > New > Target**
4. **Choose "Unit Testing Bundle"**
5. **Product Name**: `YomikaeTests`
6. **Language**: Swift
7. **Project**: Yomikae
8. **Click Finish**

### Step 2: Add Test Files to Target

1. **In Xcode Navigator**, locate the `YomikaeTests` folder
2. **Right-click** > **Add Files to "Yomikae"...**
3. **Navigate to and select**:
   - `YomikaeTests/Mocks/MockData.swift`
   - `YomikaeTests/ViewModels/SearchViewModelTests.swift`
   - `YomikaeTests/Database/DatabaseManagerTests.swift`
4. **Ensure** "YomikaeTests" target is checked
5. **Click Add**

### Step 3: Configure Test Target

1. **Select YomikaeTests target**
2. **Build Phases > Dependencies**
3. **Add Yomikae app** as a dependency
4. **General > Frameworks and Libraries**
5. **Add GRDB** if not already included

---

## Running Tests

### Run All Tests
```bash
# Command line
xcodebuild test \
  -project Yomikae.xcodeproj \
  -scheme Yomikae \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode
Cmd + U
```

### Run Specific Test File
```bash
# SearchViewModel tests only
xcodebuild test \
  -project Yomikae.xcodeproj \
  -scheme Yomikae \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:YomikaeTests/SearchViewModelTests
```

### Run Single Test
```swift
// In Xcode, click the diamond icon next to test method
func testSearchReturnsResultsForValidKanji() async throws { ... }
```

---

## Using SwiftUI Previews

### In Xcode Canvas

1. **Open any view file** (e.g., `ComponentPreviews.swift`)
2. **Editor > Canvas** (or `Cmd + Option + Enter`)
3. **Click "Resume"** to see live preview
4. **Select different previews** from dropdown

### Preview Multiple Variants

All component states are previewed:
- Normal vs error states
- Empty vs populated data
- Light vs dark mode
- Different severity levels

### Interactive Previews

Some previews are interactive:
- SearchBar accepts text input
- Buttons can be tapped
- Navigation works

---

## Test Data

### Available Mock Characters

| Character | JLPT | Meanings (JP) | Meanings (CN) |
|-----------|------|---------------|---------------|
| 手 | N5 | hand | hand, skill |
| 日 | N5 | day, sun, Japan | day, sun, date |
| 学 | N5 | learning, science | study, learn, school |

### Available Mock False Friends

| Characters | Severity | JP Meaning | CN Meaning |
|------------|----------|------------|------------|
| 勉強 | Critical | to study | reluctantly |
| 娘 | High | daughter | mother |
| 大家 | Moderate | master, expert | everyone |
| 手紙 | Low | letter | toilet paper |

---

## Writing New Tests

### ViewModel Test Template

```swift
import XCTest
@testable import Yomikae

@MainActor
final class MyViewModelTests: XCTestCase {
    var sut: MyViewModel!

    override func setUp() async throws {
        try await super.setUp()
        sut = MyViewModel()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func testFeature() async throws {
        // Given
        let input = "test"

        // When
        sut.performAction(input)

        // Then
        XCTAssertEqual(sut.result, expectedValue)
    }
}
```

### Database Test Template

```swift
import XCTest
import GRDB
@testable import Yomikae

final class MyDatabaseTests: XCTestCase {
    var sut: DatabaseManager!
    var testDatabasePath: String!

    override func setUp() async throws {
        try await super.setUp()
        let tempDir = FileManager.default.temporaryDirectory
        testDatabasePath = tempDir.appendingPathComponent("test_\(UUID().uuidString).db").path
        sut = try DatabaseManager(path: testDatabasePath)
    }

    override func tearDown() async throws {
        sut = nil
        if let path = testDatabasePath {
            try? FileManager.default.removeItem(atPath: path)
        }
        try await super.tearDown()
    }

    func testDatabaseOperation() throws {
        // Given
        let data = MockData.character手

        // When
        try sut.insertCharacter(data)

        // Then
        let retrieved = try sut.getCharacter(data.character)
        XCTAssertNotNil(retrieved)
    }
}
```

### SwiftUI Preview Template

```swift
#Preview("MyView - State Description") {
    MyView(parameter: PreviewData.mockValue)
}

#Preview("MyView - Dark Mode") {
    MyView()
        .preferredColorScheme(.dark)
}
```

---

## Test Best Practices

### 1. Use Given-When-Then Structure

```swift
func testExample() {
    // Given - Set up test data
    let input = "test"

    // When - Perform action
    sut.process(input)

    // Then - Verify result
    XCTAssertEqual(sut.output, "expected")
}
```

### 2. Test One Thing Per Test

```swift
// Good
func testSearchReturnsResults() { ... }
func testSearchHandlesEmptyQuery() { ... }

// Bad
func testSearchFunctionality() {
    // Tests multiple scenarios in one test
}
```

### 3. Use Descriptive Test Names

```swift
// Good
func testSearchReturnsResultsForValidKanji()
func testEmptyQueryReturnsEmptyResults()

// Bad
func testSearch()
func testCase1()
```

### 4. Clean Up Resources

```swift
override func tearDown() async throws {
    sut = nil
    // Clean up any files, close connections, etc.
    try await super.tearDown()
}
```

### 5. Use Mock Data

```swift
// Use shared mock data
let character = MockData.character手

// Don't create new data in every test
// (unless testing edge cases)
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v2

    - name: Run tests
      run: |
        xcodebuild test \
          -project Yomikae.xcodeproj \
          -scheme Yomikae \
          -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Test Coverage

### View Coverage Report

```bash
# Generate coverage report
xcodebuild test \
  -project Yomikae.xcodeproj \
  -scheme Yomikae \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# View in Xcode
# Product > Test (Cmd+U)
# Then: View > Navigators > Reports
# Select test run > Coverage tab
```

### Target Coverage Goals

- **ViewModels**: 80%+ coverage
- **Database Layer**: 90%+ coverage
- **Business Logic**: 85%+ coverage
- **UI Components**: Previews for all variants

---

## Troubleshooting

### Tests Won't Run

**Issue**: "YomikaeTests target not found"
**Solution**: Create test target (see Step 1 above)

**Issue**: "Cannot find 'MockData' in scope"
**Solution**: Add MockData.swift to YomikaeTests target

**Issue**: "No such module 'GRDB'"
**Solution**: Add GRDB to test target's frameworks

### Tests Fail

**Issue**: Async tests timeout
**Solution**: Increase debounce wait time (400ms+)

**Issue**: Database tests fail
**Solution**: Ensure cleanup in tearDown, use unique DB paths

**Issue**: "Cannot find type 'Character' in scope"
**Solution**: Ensure test target can access main app (@testable import Yomikae)

### Previews Don't Work

**Issue**: Preview crashes
**Solution**: Check PreviewData has all required fields

**Issue**: Preview shows "Failed to build"
**Solution**: Ensure ComponentPreviews.swift is in main target, not test target

---

## Next Steps

### Additional Tests to Add

1. **FalseFriendsViewModel Tests**
   - Filter by severity
   - Filter by category
   - Search false friends

2. **Repository Tests**
   - CharacterRepository
   - FalseFriendRepository
   - Error handling

3. **UI Tests** (Optional)
   - End-to-end search flow
   - Navigation flows
   - Accessibility

4. **Integration Tests**
   - Full database import
   - Search with real data
   - Performance benchmarks

---

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Swift Testing Best Practices](https://www.swiftbysundell.com/articles/unit-testing-in-swift/)
- [SwiftUI Previews Guide](https://developer.apple.com/documentation/swiftui/previews-in-xcode)
- [GRDB Testing Guide](https://github.com/groue/GRDB.swift#database-pools)

---

**Created**: 2025-12-02
**Last Updated**: 2025-12-02
**Test Files Status**: ✅ Created, ⚠️ Need to be added to Xcode target
