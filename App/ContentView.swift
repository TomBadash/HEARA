import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var model: QuoteModel
    @State private var search = ""
    @State private var categoryFilter = ""
    @State private var subcategoryFilter = ""
    @State private var favorites = false
    @State private var editing: Quote?
    @State private var deleting: Quote?
    @State private var importing = false
    @State private var exporting = false
    @State private var document = QuoteDocument(data: Data())
    @State private var help = false
    @State private var showTutorial = false
    var filtered: [Quote] {
        model.state.quotes.filter {
            (!favorites || $0.fav) && (categoryFilter.isEmpty || $0.category == categoryFilter) && (subcategoryFilter.isEmpty || $0.subcategory == subcategoryFilter) && (search.isEmpty ||
            ($0.text + " " + ($0.source ?? "")).localizedCaseInsensitiveContains(search))
        }
    }
    var body: some View {
        NavigationStack {
            List {
                Section("On your screen") {
                    if model.state.hidden { Text("Quote hidden").foregroundStyle(.secondary) }
                    else if let quote = model.state.current {
                        QuoteContent(quote: quote, color: model.state.quoteColor, design: model.state.quoteDesign)
                    } else { Text("No quotes available") }
                    HStack {
                        Button("Another quote", systemImage: "shuffle") { model.update { $0.shuffle() } }
                            .disabled(model.state.pool.isEmpty)
                        Spacer()
                        Button(model.state.hidden ? "Show" : "Hide", systemImage: "eye") {
                            model.update { $0.hidden.toggle() }
                        }
                    }.buttonStyle(.borderless)
                }
                Section {
                    Toggle("Shuffle favorites only", isOn: Binding(get: { model.state.favoritesOnly }, set: { value in
                        model.update { $0.favoritesOnly = value; $0.shuffle() }
                    }))
                    Picker("Language", selection: Binding(get: { model.state.language }, set: { value in
                        model.update { $0.language = value }
                    })) {
                        Text("System").tag("system")
                        Text("עברית").tag("he")
                        Text("English").tag("en")
                    }
                }
                Section {
                    NavigationLink("Appearance") { AppearanceView(model: model) }
                    NavigationLink("Quotes I receive") { FeedFilterView(model: model) }
                    NavigationLink("Explore collections") { CollectionView(model: model) }
                }
                Section("My quotes") {
                    Picker("Category", selection: $categoryFilter) {
                        Text("All categories").tag("")
                        ForEach(Array(Set(model.state.quotes.map(\.category))).sorted(), id: \.self) { Text(LocalizedStringKey($0)).tag($0) }
                    }.onChange(of: categoryFilter) { _, _ in subcategoryFilter = "" }
                    Picker("Subcategory", selection: $subcategoryFilter) {
                        Text("All subcategories").tag("")
                        ForEach(Array(Set(model.state.quotes.filter { categoryFilter.isEmpty || $0.category == categoryFilter }.compactMap(\.subcategory))).filter { !$0.isEmpty }.sorted(), id: \.self) { Text(LocalizedStringKey($0)).tag($0) }
                    }
                    Toggle("Favorites only", isOn: $favorites)
                    if filtered.isEmpty { ContentUnavailableView("No quotes available", systemImage: "quote.bubble") }
                    ForEach(filtered) { quote in
                        VStack(alignment: .leading, spacing: 12) {
                            QuoteContent(quote: quote, color: model.state.quoteColor, design: model.state.quoteDesign)
                            ViewThatFits(in: .horizontal) {
                                HStack { controls(quote) }
                                VStack(alignment: .leading) { controls(quote) }
                            }.buttonStyle(.borderless)
                        }.padding(.vertical, 8)
                    }
                }
                Section("Your collection") {
                    Button("Import backup", systemImage: "square.and.arrow.down") { importing = true }
                    Button("Export backup", systemImage: "square.and.arrow.up") {
                        do {
                            document = QuoteDocument(data: try JSONEncoder().encode(model.state.quotes))
                            exporting = true
                        } catch { model.error = error.localizedDescription }
                    }
                    Text("Stored on this device. Export a backup to move your quotes.").font(.footnote).foregroundStyle(.secondary)
                    Button("Add the Lock Screen widget", systemImage: "lock.rectangle") { help = true }
                    Button("Replay tutorial", systemImage: "play.rectangle") { showTutorial = true }
                }
            }
            .navigationTitle("Rega")
            .searchable(text: $search, prompt: "Search quotes or authors")
            .toolbar { ToolbarItem(placement: .primaryAction) {
                Button("New quote", systemImage: "plus") { editing = Quote(text: "") }
            } }
            .fullScreenCover(isPresented: $showTutorial) { OnboardingView(model: model) { showTutorial = false } }
            .sheet(item: $editing) { quote in
                QuoteEditor(quote: quote) { saved in
                    model.update { state in
                        if let i = state.quotes.firstIndex(where: { $0.id == saved.id }) { state.quotes[i] = saved }
                        else { state.quotes.insert(saved, at: 0) }
                    }
                }
            }
            .confirmationDialog("Delete this quote?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let quote = deleting {
                        model.update { state in
                            state.quotes.removeAll { $0.id == quote.id }
                            if state.selectedID == quote.id { state.shuffle() }
                        }
                    }
                    deleting = nil
                }
                Button("Cancel", role: .cancel) { deleting = nil }
            }
            .alert("Something needs attention", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
                Button("OK") { model.error = nil }
            } message: { Text(model.error ?? "") }
            .sheet(isPresented: $help) {
                NavigationStack {
                    ScrollView { Text("widget_help").padding(24).frame(maxWidth: .infinity, alignment: .leading) }
                        .navigationTitle("Lock Screen widget")
                        .toolbar { Button("Done") { help = false } }
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get()
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    try QuoteStore.importQuotes(Data(contentsOf: url))
                    model.reload()
                } catch { model.error = error.localizedDescription }
            }
            .fileExporter(isPresented: $exporting, document: document, contentType: .json, defaultFilename: "rega-quotes") { result in
                if case .failure(let error) = result { model.error = error.localizedDescription }
            }
        }
    }
    @ViewBuilder func controls(_ quote: Quote) -> some View {
        Button(quote.fav ? "Remove favorite" : "Favorite", systemImage: quote.fav ? "heart.fill" : "heart") {
            model.update { state in if let i = state.quotes.firstIndex(where: { $0.id == quote.id }) { state.quotes[i].fav.toggle() } }
        }
        Button("Edit", systemImage: "pencil") { editing = quote }
        Button("Delete", systemImage: "trash", role: .destructive) { deleting = quote }
    }
}
struct QuoteContent: View {
    let quote: Quote
    var color: Color = .primary
    var design: Font.Design = .default
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text).font(.system(.title3, design: design)).foregroundStyle(color).fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, quote.layout)
            if let url = quote.safeURL {
                Link(quote.source?.isEmpty == false ? quote.source! : String(localized: "View source"), destination: url)
                    .font(.caption)
            } else if let source = quote.source, !source.isEmpty { Text(source).font(.caption).foregroundStyle(.secondary) }
        }
    }
}
struct QuoteEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var quote: Quote
    @State private var error: String?
    let save: (Quote) -> Void
    var body: some View {
        NavigationStack {
            Form {
                Section("Your words") {
                    TextEditor(text: $quote.text).frame(minHeight: 130)
                        .environment(\.layoutDirection, quote.layout)
                    Text("\(quote.text.count)/240").font(.caption).foregroundStyle(.secondary)
                }
                Section("Source (optional)") {
                    TextField("Author, book or talk", text: Binding(get: { quote.source ?? "" }, set: { quote.source = $0 }))
                    TextField("Source link", text: Binding(get: { quote.sourceUrl ?? "" }, set: { quote.sourceUrl = $0 }))
                        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                        .environment(\.layoutDirection, .leftToRight)
                }
                Picker("Quote direction", selection: Binding(get: { quote.direction ?? "auto" }, set: { quote.direction = $0 })) {
                    Text("Automatic").tag("auto"); Text("Right to left").tag("rtl"); Text("Left to right").tag("ltr")
                }
                Section("Classification") {
                    TextField("Category", text: $quote.category)
                    TextField("Subcategory", text: Binding(get: { quote.subcategory ?? "" }, set: { quote.subcategory = $0 }))
                }
                Toggle("Favorite", isOn: $quote.fav)
                if let error { Text(error).foregroundStyle(.red) }
            }
            .navigationTitle("Edit quote")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") {
                    do {
                        quote.text = quote.text.trimmingCharacters(in: .whitespacesAndNewlines)
                        quote.category = quote.category.trimmingCharacters(in: .whitespacesAndNewlines)
                        if quote.category.isEmpty { quote.category = "אישי" }
                        quote.subcategory = quote.subcategory?.trimmingCharacters(in: .whitespacesAndNewlines)
                        try quote.validate(); save(quote); dismiss()
                    } catch { self.error = error.localizedDescription }
                } }
            }
        }
    }
}
