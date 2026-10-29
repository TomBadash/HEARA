import Foundation
import WidgetKit

// Both processes coordinate the entire read-modify-write transaction.
enum QuoteStore {
    static let kind = "RegaQuote"
    static func fileURL() throws -> URL {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "RegaAppGroup") as? String,
              let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        else { throw StoreError.groupUnavailable }
        return root.appendingPathComponent("quotes-v1.json")
    }
    private static func decode(_ url: URL) throws -> QuoteState {
        if !FileManager.default.fileExists(atPath: url.path) { return QuoteState() }
        return try JSONDecoder().decode(QuoteState.self, from: Data(contentsOf: url))
    }
    static func load() throws -> QuoteState {
        let url = try fileURL()
        var coordinationError: NSError?
        var result: Result<QuoteState, Error>?
        NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinationError) { location in
            result = Result { try decode(location) }
        }
        if let coordinationError { throw coordinationError }
        return try result.unwrap().get()
    }
    @discardableResult
    static func update(_ change: (inout QuoteState) throws -> Void) throws -> QuoteState {
        let url = try fileURL()
        var coordinationError: NSError?
        var result: Result<QuoteState, Error>?
        NSFileCoordinator().coordinate(writingItemAt: url, options: [], error: &coordinationError) { location in
            result = Result {
                var state = try decode(location)
                try change(&state)
                let data = try JSONEncoder().encode(state)
                try data.write(to: location, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
                return state
            }
        }
        if let coordinationError { throw coordinationError }
        let state = try result.unwrap().get()
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        return state
    }
    static func importQuotes(_ data: Data) throws {
        guard data.count <= 1_000_000 else { throw StoreError.invalidBackup }
        let incoming = try JSONDecoder().decode([Quote].self, from: data)
        guard incoming.count <= 2000, Set(incoming.map(\.id)).count == incoming.count else { throw StoreError.invalidBackup }
        try incoming.forEach { try $0.validate() }
        try update { state in
            for var quote in incoming where !state.quotes.contains(where: { $0.text == quote.text }) {
                quote.id = UUID().uuidString
                state.quotes.append(quote)
            }
            guard state.quotes.count <= 2000 else { throw StoreError.invalidBackup }
        }
    }
}
private extension Optional {
    func unwrap() throws -> Wrapped {
        guard let self else { throw StoreError.groupUnavailable }
        return self
    }
}
