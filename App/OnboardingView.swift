import SwiftUI

/// First screen is always English. The tutorial follows the explicitly chosen language.
struct OnboardingView: View {
    @ObservedObject var model: QuoteModel
    let finish: () -> Void
    @State private var step = 0
    @State private var language = "en"
    @State private var previewHidden = false
    @State private var previewIndex = 0
    private var hebrew: Bool { step > 1 && language == "he" }
    private func copy(_ en: String, _ he: String) -> String { hebrew ? he : en }
    private var demoQuotes: [String] {
        hebrew ? ["גם צעד קטן קדימה הוא עדיין התקדמות.", "בחר במה שחשוב לך, ותן לזה מקום."] :
            ["One small step is still a step forward.", "Make room for what matters to you."]
    }
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Text("HEARA").font(.system(size: 36, weight: .bold, design: .rounded))
                        Spacer()
                        Text("\(step + 1) / 4").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 15)
                    Image(systemName: step == 0 ? "sparkles" : step == 1 ? "globe" : step == 2 ? "quote.bubble" : "lock.rectangle")
                        .font(.system(size: 50)).foregroundStyle(.green)
                        .accessibilityHidden(true)
                    if step == 0 {
                        Text("A little light.\nEvery glance.")
                            .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                        Text("We believe inspiration begins with a small spark.\nThe right words, at the right moment, can shift your perspective, lift your spirit, and help you take the next step.")
                        Text("Keep words that matter close.\nLet every glance hold a little possibility.").foregroundStyle(.secondary)
                    } else if step == 1 {
                        Text("Make yourself at home.").font(.largeTitle.bold())
                        Text("Choose your language. You can change it later in the app.")
                        languageChoice("English", subtitle: "Left to right", code: "en")
                        languageChoice("עברית", subtitle: "ימין לשמאל", code: "he")
                    } else if step == 2 {
                        Text(copy("Words that move with you.", "מילים שממשיכות איתך.")).font(.largeTitle.bold())
                        Text(copy("Add your own quotes, save favorites, and include an author or source when you know it.", "הוסף משפטים משלך, שמור מועדפים וציין מחבר או מקור כשידוע לך."))
                        VStack(alignment: .leading, spacing: 18) {
                            Text(previewHidden ? copy("Quote hidden", "המשפט מוסתר") : demoQuotes[previewIndex])
                                .font(.title3).frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityIdentifier("onboarding.preview")
                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: 20) { demoControls }
                                VStack(alignment: .leading, spacing: 20) { demoControls }
                            }
                        }.padding(24).background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
                        Text(copy("Try it here. This is a preview, not your actual Lock Screen widget.", "נסה כאן. זו הדמיה, לא הווידג׳ט האמיתי במסך הנעילה.")).font(.footnote).foregroundStyle(.secondary)
                    } else {
                        Text(copy("One last little step.", "עוד צעד קטן.")).font(.largeTitle.bold())
                        Text(copy("Add HEARA to your Lock Screen", "הוסף את הארה למסך הנעילה")).font(.title2.bold())
                        instruction("1", "Open HEARA once, then touch and hold your Lock Screen.", "פתח את הארה פעם אחת, ואז לחץ לחיצה ארוכה על מסך הנעילה.")
                        instruction("2", "Choose Customize → Lock Screen → Add Widgets.", "בחר התאמה אישית ← מסך נעילה ← הוסף ווידג׳טים.")
                        instruction("3", "Choose HEARA and add the rectangular widget.", "בחר הארה והוסף את הווידג׳ט המלבני.")
                        Label(copy("No permissions to grant", "אין צורך במתן הרשאות"), systemImage: "checkmark.shield").font(.headline)
                        Text(copy("HEARA does not need notifications, camera, microphone or location access. You add the widget yourself in iOS. Face ID or your passcode may be needed to use its buttons while locked.", "הארה לא צריכה גישה להתראות, למצלמה, למיקרופון או למיקום. את הווידג׳ט מוסיפים דרך iOS. להפעלת הכפתורים במכשיר נעול ייתכן שיידרשו Face ID או קוד."))
                        Text(copy("You can add it later. This screen does not verify that the widget was added.", "אפשר להוסיף אותו גם בהמשך. המסך הזה אינו בודק שהווידג׳ט נוסף.")).font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 15)
                    if let error = model.error { Text(error).font(.footnote).foregroundStyle(.red) }
                    Button {
                        if step < 3 { step += 1 }
                        else if model.update({ $0.language = language }) { finish() }
                    } label: {
                        Text(step == 0 ? "Find your spark" : step == 3 ? copy("Start my collection", "למאגר שלי") : copy("Continue", "המשך"))
                            .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 10)
                    }.buttonStyle(.borderedProminent).controlSize(.large)
                    .accessibilityIdentifier("onboarding.continue")
                    if step > 0 {
                        Button(copy("Back", "חזרה")) { step -= 1 }
                            .frame(maxWidth: .infinity).padding(.bottom, 8)
                    }
                }
                .padding(28).frame(maxWidth: 540, minHeight: geometry.size.height, alignment: .leading)
                .frame(maxWidth: .infinity)
            }.background(Color(red: 0.97, green: 0.96, blue: 0.93))
        }
        .environment(\.locale, Locale(identifier: hebrew ? "he" : "en"))
        .environment(\.layoutDirection, hebrew ? .rightToLeft : .leftToRight)
        .interactiveDismissDisabled()
        .onAppear { language = model.state.language == "he" ? "he" : "en" }
    }
    @ViewBuilder private var demoControls: some View {
        Button { previewIndex = (previewIndex + 1) % demoQuotes.count; previewHidden = false } label: {
            Label(copy("Shuffle", "הגרלה"), systemImage: "shuffle")
        }
        Button { previewHidden.toggle() } label: {
            Label(previewHidden ? copy("Show", "הצג") : copy("Hide", "הסתר"), systemImage: previewHidden ? "eye" : "eye.slash")
        }
    }
    private func languageChoice(_ title: String, subtitle: String, code: String) -> some View {
        Button { language = code } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: language == code ? "checkmark.circle.fill" : "circle")
            }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(language == code ? Color.green : Color.clear, lineWidth: 2))
        }.buttonStyle(.plain)
            .accessibilityAddTraits(language == code ? [.isSelected] : [])
    }
    private func instruction(_ number: String, _ en: String, _ he: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number).font(.headline).foregroundStyle(.green).accessibilityHidden(true)
            Text(copy(en, he)).fixedSize(horizontal: false, vertical: true)
        }
    }
}
