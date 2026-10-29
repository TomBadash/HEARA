import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class QuoteModel: ObservableObject {
    @Published var state = QuoteState()
    @Published var error: String?
    func reload() {
        do { state = try QuoteStore.load() } catch { self.error = error.localizedDescription }
    }
    @discardableResult
    func update(_ change: (inout QuoteState) throws -> Void) -> Bool {
        do { state = try QuoteStore.update(change); error = nil; return true } catch { self.error = error.localizedDescription; return false }
    }
}
@main
struct RegaApp: App {
    @StateObject private var model = QuoteModel()
    @AppStorage("rega-onboarding-v1") private var onboardingComplete = false
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingComplete { ContentView(model: model) }
                else { OnboardingView(model: model) { onboardingComplete = true } }
            }
                .environment(\.locale, model.state.locale)
                .environment(\.layoutDirection, model.state.layout)
                .tint(Color(red: 0.15, green: 0.32, blue: 0.24))
                .onAppear { model.reload() }
                .onChange(of: phase) { _, phase in if phase == .active { model.reload() } }
        }
    }
}
struct QuoteDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
