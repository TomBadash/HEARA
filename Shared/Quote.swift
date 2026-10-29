import Foundation
import SwiftUI

struct Quote: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var text: String
    var category = "אישי"
    var fav = false
    var source: String? = nil
    var sourceUrl: String? = nil
    var direction: String? = "auto"
    var subcategory: String? = nil
    var subcategoryKey: String { category + "\u{1F}" + (subcategory ?? "") }
    var safeURL: URL? {
        guard let raw = sourceUrl, let url = URL(string: raw),
              ["https", "http"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { return nil }
        return url
    }
    var layout: LayoutDirection {
        if direction == "rtl" { return .rightToLeft }
        if direction == "ltr" { return .leftToRight }
        // Use the first strong letter, leaving numbers and punctuation neutral.
        for scalar in text.unicodeScalars where CharacterSet.letters.contains(scalar) {
            return (0x0590...0x08FF).contains(scalar.value) ? .rightToLeft : .leftToRight
        }
        return .leftToRight
    }
    func validate() throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              text.count <= 240, category.count <= 80, (subcategory?.count ?? 0) <= 80, (source?.count ?? 0) <= 160,
              ["auto", "rtl", "ltr"].contains(direction ?? "auto"),
              sourceUrl?.isEmpty != false || safeURL != nil else { throw StoreError.invalidQuote }
    }
}
struct QuoteState: Codable {
    var quotes: [Quote] = [
        Quote(text: "גם צעד קטן קדימה הוא עדיין התקדמות.", category: "צמיחה", fav: true),
        Quote(text: "מותר לעצור לנשום. גם מנוחה היא חלק מהדרך.", category: "איזון"),
        Quote(text: "בחר במה שחשוב לך, ותן לזה מקום.")
    ]
    var selectedID: String? = nil
    var hidden = false
    var favoritesOnly = false
    var language = "system"
    // Optional fields preserve compatibility with pre-settings backups.
    var selectedCategories: [String]? = nil
    var selectedSubcategories: [String]? = nil
    var textColor: String? = nil
    var fontChoice: String? = nil
    var current: Quote? { pool.first { $0.id == selectedID } ?? pool.first }
    var pool: [Quote] { quotes.filter { quote in
        (!favoritesOnly || quote.fav) &&
        (selectedCategories?.contains(quote.category) ?? true) &&
        (selectedSubcategories?.contains(quote.subcategoryKey) ?? true)
    } }
    var quoteColor: Color { Appearance.color(textColor ?? "automatic") }
    var quoteDesign: Font.Design { Appearance.design(fontChoice ?? "default") }
    mutating func shuffle() {
        let alternatives = pool.filter { $0.id != current?.id }
        selectedID = (alternatives.isEmpty ? pool : alternatives).randomElement()?.id
        hidden = false
    }
    var locale: Locale { language == "system" ? .current : Locale(identifier: language) }
    var layout: LayoutDirection {
        let code = language == "system" ? (Locale.preferredLanguages.first ?? "en") : language
        return code.hasPrefix("he") || code.hasPrefix("ar") ? .rightToLeft : .leftToRight
    }
}
enum StoreError: LocalizedError {
    case groupUnavailable, invalidQuote, invalidBackup
    var errorDescription: String? {
        switch self {
        case .groupUnavailable: return "Shared storage unavailable. Check App Groups signing for both targets."
        case .invalidQuote: return "Check the quote length (1–240), source (up to 160), direction and http/https link."
        case .invalidBackup: return "Invalid backup: expected an array of up to 2000 quotes with unique IDs."
        }
    }
}
