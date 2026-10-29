import XCTest
@testable import Rega

final class QuoteTests: XCTestCase {
    func testShuffleDoesNotRepeatWhenAlternativesExist() {
        var state = QuoteState()
        state.selectedID = state.quotes[0].id
        for _ in 0..<50 {
            let previous = state.current?.id
            state.shuffle()
            XCTAssertNotEqual(previous, state.current?.id)
        }
    }
    func testNoFavoritesDoesNotLeakOtherQuotes() {
        var state = QuoteState(quotes: [Quote(text: "Hello")])
        state.favoritesOnly = true
        state.shuffle()
        XCTAssertNil(state.current)
    }
    func testBackupRemainsCompatibleWithWebFormat() throws {
        let data = Data(#"[{"id":"web-id","text":"Hello","category":"אישי","fav":true}]"#.utf8)
        let quote = try JSONDecoder().decode([Quote].self, from: data)[0]
        XCTAssertNil(quote.source)
        try quote.validate()
        XCTAssertEqual(quote.layout, .leftToRight)
    }
    func testDirectionsAndUnsafeSources() throws {
        XCTAssertEqual(Quote(text: "123 שלום world").layout, .rightToLeft)
        XCTAssertEqual(Quote(text: "123 Hello שלום").layout, .leftToRight)
        var quote = Quote(text: "Hello")
        quote.sourceUrl = "javascript:alert(1)"
        XCTAssertThrowsError(try quote.validate())
        quote.sourceUrl = "https://example.com"
        XCTAssertNoThrow(try quote.validate())
        quote.text = String(repeating: "a", count: 241)
        XCTAssertThrowsError(try quote.validate())
    }

    func testCategoryAndSubcategoryFilteringNeverLeaksExcludedQuote() {
        var state = QuoteState(quotes: [
            Quote(id: "a", text: "A", category: "Judaism", fav: true, subcategory: "Hope"),
            Quote(id: "b", text: "B", category: "Islam", fav: true, subcategory: "Hope"),
            Quote(id: "c", text: "C", category: "Judaism", subcategory: "Peace")
        ])
        state.selectedID = "b"
        state.selectedCategories = ["Judaism"]
        state.selectedSubcategories = [state.quotes[0].subcategoryKey]
        state.favoritesOnly = true
        XCTAssertEqual(state.pool.map(\.id), ["a"])
        XCTAssertEqual(state.current?.id, "a")
        state.selectedCategories = []
        XCTAssertNil(state.current)
    }
    func testOldStateMigratesAndCollectionsValidate() throws {
        let data = Data(#"{"quotes":[],"hidden":false,"favoritesOnly":false,"language":"en"}"#.utf8)
        let state = try JSONDecoder().decode(QuoteState.self, from: data)
        XCTAssertNil(state.textColor)
        XCTAssertNil(state.selectedCategories)
        XCTAssertEqual(Set(QuoteCollections.quotes.map(\.id)).count, QuoteCollections.quotes.count)
        try QuoteCollections.quotes.forEach { try $0.validate() }
    }
}
