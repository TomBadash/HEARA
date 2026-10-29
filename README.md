# רגע / Rega — iOS source project, v0.1

Native SwiftUI app and WidgetKit extension for iOS 17+. This is a source handoff, **not a compiled or signed application**. No Xcode or Swift compiler is available in the authoring environment. An actual macOS build and device QA remain required; the included CI workflow has not been run.

## Included

- Add/edit/delete quotes, favorites, search, categories and source labels/links.
- Shared app-group JSON, coordinated read-modify-write and atomic writes.
- Lock Screen rectangular widget; small/medium Home Screen widgets.
- App Intents for shuffle (avoids immediate repeats) and hide/show.
- Hebrew/English/system language, quote-specific direction, native adaptive lists, Dynamic Type, iPhone/iPad targets.
- JSON import/export compatible with the existing browser prototype. Import merges by exact text and keeps existing records; it never replaces the collection. Import validation is completed before writing.
- XCTest source for shuffle, favorites, backup compatibility, direction and source validation.

## From Windows

1. Extract this ZIP. You can edit source with VS Code on Windows.
2. For a build without buying a Mac, put these files at the root of a **private GitHub repository** and enable Actions. Include the `.github` directory. The supplied macOS workflow generates the project and builds/tests in an iOS simulator. Check GitHub's current plan/billing before running macOS jobs. This package does not create a repository or trigger CI for you.
3. To interact with the simulator, sign the app or send it to TestFlight, use a Mac you can access or a macOS cloud environment with Xcode. The unsigned CI build alone is not installable on your iPhone.
4. Before paid services or account enrollment, run the simulator build and resolve any compiler errors it identifies. No build success is claimed here.

## On macOS with Xcode

Install Apple's Xcode and its command-line tools, then XcodeGen from its official Homebrew package:

```sh
brew install xcodegen
xcodegen generate
open Rega.xcodeproj
```

Select the Rega scheme and an iPhone simulator, then Run. Both targets must have the same App Group. If simulator storage setup fails, check the generated entitlements and Signing & Capabilities; the app intentionally shows an error instead of silently using a different store from the widget.

## Signing and TestFlight

Before device deployment, replace these placeholder values in `project.yml`:

- `REGA_BUNDLE_ID`: your globally unique reverse-DNS app ID.
- `REGA_APP_GROUP`: your registered group ID starting with `group.`.
- `DEVELOPMENT_TEAM`: your Apple developer team ID.

Run `xcodegen generate` again. In Apple's developer account register the app ID and extension ID (`<app ID>.widget`) and enable the same App Group for both. Check both targets' Signing & Capabilities. Build on device before archiving. TestFlight distribution requires Apple Developer Program membership, App Store Connect setup and a signed archive. No signing credentials belong in the repository or ZIP. Enter them directly into the selected trusted build service.

This version has no production icon, store screenshots or listing. Those and a privacy policy/listing review are still needed before store submission. It uses no analytics, network service or account. External source links open only when chosen by the user.

## Try the real widget

Run the app once, add a short quote, then use iPhone Lock Screen customization → Add Widgets → Rega. Rectangular Lock Screen space is small; long quotes are truncated. Tap shuffle and hide/show; locked-device interaction can require Face ID/passcode authentication. Hide clears quote content, but the widget area and show button remain. Removing the entire widget requires the system editor.

The widget does not automatically rotate on a schedule in this version. Updates follow app changes or widget actions; iOS controls rendering. No Live Activity is used. Source labels appear when known; source links are opened from the app. The initial demonstration phrases have no claimed attribution.

## Move quotes from the prototype

In the browser prototype choose Export backup, transfer `rega-quotes.json` to Files on iPhone, and choose Import backup in Rega. Browser and native stores are separate; there is no automatic sync. Existing prototype quotes are not embedded in this package.

## Before calling this a working beta

Run the included build and XCTest workflow on macOS. Then verify on actual iPhones:

- Narrow and wide screens; portrait/landscape; largest accessibility text size; VoiceOver.
- Hebrew, English and mixed text, including a Hebrew quote in English UI and the reverse.
- Short/long quote and source; no source; link-only source.
- Shuffle/hide/show while locked and authenticated; favorites collection empty or with one item.
- Edit/delete/import while widget is present; relaunch app and reboot phone.
- Invalid JSON and unsafe links must fail without replacing data; backup import/export round-trip.

## Apple documentation

- https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- https://developer.apple.com/documentation/xcode/configuring-app-groups
- https://developer.apple.com/documentation/widgetkit/widgetfamily/accessoryrectangular

## First-run onboarding

An English welcome leads to explicit English/Hebrew selection, an interactive shuffle/hide preview, and manual widget setup instructions. No system permission prompts are needed for the current feature set. The flow does not claim that the widget has been installed. Completion is stored only after the shared language setting saves successfully. Relaunch skips onboarding; Replay tutorial opens it again from the collection section. Native scrolling and ViewThatFits accommodate narrow widths and Dynamic Type. Actual Xcode/device validation remains pending.

## Appearance, filtering and collections update

Six color presets, a custom RGB color picker and four system font designs apply to app quote text and full-color Home Screen widgets. iOS Lock Screen vibrant rendering overrides arbitrary text colors; this limitation is shown in Settings. Fonts may fall back for particular scripts. No custom font files are embedded.

A quote-ID-specific heart App Intent adds/removes favorites on the displayed quote. Favorites, chosen categories, and parent-qualified subcategories intersect. A nil category selection means all, an empty selection means none. Category changes reset subcategory selection to all to avoid invisible stale filters. Selection does not delete quotes. Library browsing has separate category/subcategory controls. Editing allows custom category and subcategory names.

Religious starter collections are opt-in: two source passages per tradition, each in English and Hebrew (12 records total). Judaism: Avot 1:14 excerpts; Islam: Qur’an 94:5 and 2:286 excerpts, Sahih International for English; Christianity: Matthew 5:9 and 7:7, KJV. Hebrew editorial translations are explicitly labeled, rather than presented as a canonical published translation. Sources are linked on every record. The collections are a small starting sample, not comprehensive religious libraries. Import/export includes quote classification; appearance and feed preferences remain on the device.

Additional device QA: verify heart updates while locked, including removing the last favorite; category/subcategory intersections; zero matches; old-state migration; font fallback in Hebrew; palette contrast in light/dark modes; and iOS tint overrides. Added XCTest sources have NOT been executed in Xcode.

## Branding

The product is now HEARA (הארה). Approved welcome copy is integrated in OnboardingView.swift and recorded in BRAND.md. Legacy Rega project identifiers and storage keys are retained for compatibility. App Store name availability is not confirmed.
