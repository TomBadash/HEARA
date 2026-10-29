import AppIntents

struct ShuffleQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Another quote"
    static var openAppWhenRun = false
    func perform() async throws -> some IntentResult {
        try QuoteStore.update { $0.shuffle() }
        return .result()
    }
}
struct ToggleQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Hide or show"
    static var openAppWhenRun = false
    func perform() async throws -> some IntentResult {
        try QuoteStore.update { $0.hidden.toggle() }
        return .result()
    }
}

struct FavoriteQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Favorite"
    static var openAppWhenRun = false
    @Parameter(title: "Quote") var quoteID: String
    init() {}
    init(quoteID: String) { self.quoteID = quoteID }
    func perform() async throws -> some IntentResult {
        try QuoteStore.update { state in
            // Act on the displayed quote even if another process shuffled meanwhile.
            if let index = state.quotes.firstIndex(where: { $0.id == quoteID }) {
                state.quotes[index].fav.toggle()
            }
        }
        return .result()
    }
}
