import SwiftUI
import WidgetKit

struct Entry: TimelineEntry {
    var date: Date
    var state: QuoteState
    var failed = false
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now, state: QuoteState()) }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) { completion(read()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(entries: [read()], policy: .never))
    }
    private func read() -> Entry {
        do { return Entry(date: .now, state: try QuoteStore.load()) }
        catch { return Entry(date: .now, state: QuoteState(quotes: []), failed: true) }
    }
}
struct WidgetView: View {
    let entry: Entry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    var compact: Bool { family == .accessoryRectangular }
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 2 : 10) {
            if entry.failed { Text("Open Rega to check storage").font(.caption) }
            else if entry.state.hidden { Text("Quote hidden").font(.caption) }
            else if let quote = entry.state.current {
                Text(quote.text)
                    .font(.system(compact ? .caption : .headline, design: entry.state.quoteDesign))
                    .foregroundStyle(renderingMode == .fullColor ? entry.state.quoteColor : Color.primary)
                    .lineLimit(compact ? 2 : 5)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, quote.layout)
                if let source = quote.source, !source.isEmpty {
                    Text(source).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            } else { Text("No quotes available").font(.caption) }
            HStack {
                Button(intent: ShuffleQuoteIntent()) { Image(systemName: "shuffle") }
                    .accessibilityLabel("Another quote")
                    .disabled(entry.state.pool.isEmpty || entry.failed)
                Spacer(minLength: 8)
                if let quote = entry.state.current, !entry.state.hidden {
                    Button(intent: FavoriteQuoteIntent(quoteID: quote.id)) {
                        Image(systemName: quote.fav ? "heart.fill" : "heart")
                    }.accessibilityLabel(quote.fav ? "Remove favorite" : "Favorite")
                    Spacer(minLength: 8)
                }
                Button(intent: ToggleQuoteIntent()) { Image(systemName: entry.state.hidden ? "eye" : "eye.slash") }
                    .accessibilityLabel("Hide or show").disabled(entry.failed)
            }.buttonStyle(.plain)
        }
        .containerBackground(for: .widget) { Color(red: 0.15, green: 0.32, blue: 0.24).opacity(0.12) }
        .environment(\.locale, entry.state.locale)
        .environment(\.layoutDirection, entry.state.layout)
    }
}
@main
struct RegaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: QuoteStore.kind, provider: Provider()) { WidgetView(entry: $0) }
            .configurationDisplayName("Rega")
            .description("Your words, a glance away.")
            .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}
