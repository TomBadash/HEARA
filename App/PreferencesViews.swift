import SwiftUI

struct AppearanceView: View {
    @ObservedObject var model: QuoteModel
    var body: some View {
        Form {
            Section("Preview") {
                Text(model.state.current?.text ?? "Rega")
                    .font(.system(.title2, design: model.state.quoteDesign))
                    .foregroundStyle(model.state.quoteColor)
                    .environment(\.layoutDirection, model.state.current?.layout ?? model.state.layout)
            }
            Picker("Text color", selection: Binding(get: { (model.state.textColor?.hasPrefix("#") == true ? "custom" : model.state.textColor ?? "automatic") }, set: { value in model.update { $0.textColor = value == "custom" ? "#26734D" : value } })) {
                ForEach(Appearance.colors, id: \.self) { Text(LocalizedStringKey($0)).tag($0) }
                Text("Custom").tag("custom")
            }
            ColorPicker("Custom color", selection: Binding(get: { model.state.quoteColor }, set: { value in model.update { $0.textColor = Appearance.hex(value) } }), supportsOpacity: false)
            Picker("Font", selection: Binding(get: { model.state.fontChoice ?? "default" }, set: { value in model.update { $0.fontChoice = value } })) {
                ForEach(Appearance.fonts, id: \.self) { Text(LocalizedStringKey($0)).tag($0) }
            }
            Text("iOS controls Lock Screen colors. Your selected color applies in the app and full-color Home Screen widgets; tinted appearances may override it. Font support varies by language.")
                .font(.footnote).foregroundStyle(.secondary)
        }.navigationTitle("Appearance")
    }
}
struct FeedFilterView: View {
    @ObservedObject var model: QuoteModel
    var categories: [String] { Array(Set(model.state.quotes.map(\.category))).sorted() }
    var body: some View {
        List {
            Section {
                Text("These filters control the quotes shown by shuffle and the widget. Favorites combine with these selections.").font(.footnote)
                Button("All categories") { model.update { $0.selectedCategories = nil; $0.selectedSubcategories = nil; $0.shuffle() } }
                Button("Clear selection") { model.update { $0.selectedCategories = []; $0.selectedSubcategories = nil; $0.shuffle() } }
                if model.state.pool.isEmpty { Text("No quotes match your selections").foregroundStyle(.secondary) }
            }
            ForEach(categories, id: \.self) { category in
                Section {
                    Toggle(isOn: Binding(get: { model.state.selectedCategories?.contains(category) ?? true }, set: { value in
                        model.update { state in
                            var selected = state.selectedCategories ?? categories
                            selected.removeAll { $0 == category }
                            if value { selected.append(category) }
                            state.selectedCategories = selected
                            state.selectedSubcategories = nil
                            state.shuffle()
                        }
                    })) { Text(LocalizedStringKey(category)) }
                    if model.state.selectedCategories?.contains(category) ?? true {
                        let group = model.state.quotes.filter { $0.category == category }
                        let keys = Array(Set(group.map(\.subcategoryKey))).sorted()
                        ForEach(keys, id: \.self) { key in
                            Toggle(isOn: Binding(get: { model.state.selectedSubcategories?.contains(key) ?? true }, set: { value in
                                model.update { state in
                                    var selected = state.selectedSubcategories ?? Array(Set(state.quotes.map(\.subcategoryKey)))
                                    selected.removeAll { $0 == key }
                                    if value { selected.append(key) }
                                    state.selectedSubcategories = selected
                                    state.shuffle()
                                }
                            })) {
                                Text(LocalizedStringKey(group.first { $0.subcategoryKey == key }?.subcategory.flatMap { $0.isEmpty ? nil : $0 } ?? "Uncategorized"))
                            }.padding(.leading, 16)
                        }
                    }
                }
            }
        }.navigationTitle("Quotes I receive")
    }
}
struct CollectionView: View {
    @ObservedObject var model: QuoteModel
    var body: some View {
        List {
            Text("Add only the collections you want. Then choose categories and subcategories in Quotes I receive.").font(.footnote)
            ForEach(QuoteCollections.names, id: \.self) { name in
                Section {
                    Text(LocalizedStringKey(name)).font(.headline)
                    ForEach(QuoteCollections.quotes.filter { $0.category == name }) { quote in
                        QuoteContent(quote: quote)
                    }
                    Button("Add collection", systemImage: "plus") {
                        model.update { state in
                            for quote in QuoteCollections.quotes where quote.category == name {
                                if !state.quotes.contains(where: { $0.id == quote.id || $0.text == quote.text }) { state.quotes.append(quote) }
                            }
                        }
                    }.disabled(QuoteCollections.quotes.filter { $0.category == name }.allSatisfy { item in model.state.quotes.contains { $0.id == item.id || $0.text == item.text } })
                }
            }
        }.navigationTitle("Explore collections")
    }
}
