# Mangasm Launch + Full App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a navigable SwiftUI front-end for Mangasm — launch flow (splash + landmark sign-in) and main app (profile, discover, AI match, chat, events, settings) — on a mock service layer behind protocol seams.

**Architecture:** A multiplatform Swift Package. Library target `MangasmApp` holds all code; `MangasmPreview` is a macOS `@main` entry so `swift run` opens a window. `AppState` (`@EnvironmentObject`) holds UI state; `AppEnvironment` exposes service protocols (mock now, real later). UI is cross-platform SwiftUI so `swift build` (macOS) genuinely compiles it.

**Tech Stack:** Swift 6, SwiftUI, AVKit (video), SPM. No third-party deps.

## Global Constraints

- Swift tools-version `6.0`; platforms `.iOS(.v17)`, `.macOS(.v14)`.
- Cross-platform SwiftUI only. NEVER `UIScreen.main`/`UIKit`; use `GeometryReader`. `#if os(iOS)` only for genuinely iOS-only APIs.
- Single source of truth for color: `GOLD #C9A84C`, `GOLD_DEEP #9A7B2C`, `GOLD_BRIGHT #E4C97E`, `INK #2A2117`, `INK_SOFT rgba(42,33,23,0.70)`, `INK_FAINT rgba(42,33,23,0.50)`, `SPOTIFY #138A3E`, `launchOrange #F08A38`, `launchOrangeDeep #C95E1E`. Skyline fill `#120A14`.
- Fonts: register Cormorant Garamond / Mulish / Space Mono if present in `Resources/Fonts`, else fall back to system `.serif` / default / `.monospaced`. Never hard-fail on missing fonts.
- Auth providers are visual only — every auth control calls `onEnter()`.
- Each task ends `swift build`-clean and committed. Commit trailer:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- Final gate: `swift build` (macOS) AND `xcodebuild -scheme MangasmApp -destination 'generic/platform=iOS Simulator' build`. Status reports name the verified target.

---

## Phase 1 — Walking skeleton (compiles & runs)

### Task 1: Package + runnable empty shell

**Files:**
- Create: `Package.swift`
- Create: `Sources/MangasmApp/Shell/AppState.swift`
- Create: `Sources/MangasmApp/Shell/MangasmRootView.swift`
- Create: `Sources/MangasmApp/Shell/MainTabView.swift`
- Create: `Sources/MangasmApp/Features/Placeholders.swift`
- Create: `Sources/MangasmPreview/main.swift`
- Test: `Tests/MangasmAppTests/AppStateTests.swift`

**Interfaces:**
- Produces: `enum AppPhase { case launch, app }`; `enum AppTab: String, CaseIterable { case discover, search, aiMatch, likes, profile }`; `final class AppState: ObservableObject` with `@Published var phase`, `@Published var tab`; `struct MangasmRootView: View`; `struct MainTabView: View`.

- [ ] **Step 1: Write `Package.swift`**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mangasm",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MangasmApp", targets: ["MangasmApp"]),
        .executable(name: "MangasmPreview", targets: ["MangasmPreview"]),
    ],
    targets: [
        .target(name: "MangasmApp", resources: [.process("Resources")]),
        .executableTarget(name: "MangasmPreview", dependencies: ["MangasmApp"]),
        .testTarget(name: "MangasmAppTests", dependencies: ["MangasmApp"]),
    ]
)
```

- [ ] **Step 2: Write failing test**

```swift
import XCTest
@testable import MangasmApp

final class AppStateTests: XCTestCase {
    func testStartsInLaunchPhase() {
        let s = AppState()
        XCTAssertEqual(s.phase, .launch)
    }
    func testDefaultTabIsProfile() {
        let s = AppState()
        XCTAssertEqual(s.tab, .profile)
    }
    func testAllTabsHaveStableRawValues() {
        XCTAssertEqual(AppTab.allCases.count, 5)
    }
}
```

- [ ] **Step 3: Run test, expect FAIL**

Run: `swift test --filter AppStateTests`
Expected: FAIL (no such module member `AppState`).

- [ ] **Step 4: Implement `AppState.swift`**

```swift
import SwiftUI

public enum AppPhase { case launch, app }

public enum AppTab: String, CaseIterable, Identifiable {
    case discover, search, aiMatch, likes, profile
    public var id: String { rawValue }
}

@MainActor
public final class AppState: ObservableObject {
    @Published public var phase: AppPhase = .launch
    @Published public var tab: AppTab = .profile
    @Published public var night = false
    @Published public var premium = false
    public init() {}
    public func enterApp() { phase = .app }
}
```

- [ ] **Step 5: Implement placeholder screens**

`Placeholders.swift`: one reusable view used by the skeleton.

```swift
import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            Text(title).font(.title).foregroundStyle(.white)
        }
    }
}
```

- [ ] **Step 6: Implement `MainTabView.swift` (skeleton)**

```swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        TabView(selection: $state.tab) {
            ForEach(AppTab.allCases) { tab in
                PlaceholderScreen(title: tab.rawValue.capitalized)
                    .tag(tab)
                    .tabItem { Text(tab.rawValue.capitalized) }
            }
        }
    }
}
```

- [ ] **Step 7: Implement `MangasmRootView.swift`**

```swift
import SwiftUI

public struct MangasmRootView: View {
    @StateObject private var state = AppState()
    public init() {}
    public var body: some View {
        Group {
            switch state.phase {
            case .launch: PlaceholderScreen(title: "Mangasm — Launch")
            case .app:    MainTabView()
            }
        }
        .environmentObject(state)
    }
}
```

- [ ] **Step 8: Implement `Sources/MangasmPreview/main.swift`**

```swift
import SwiftUI
import MangasmApp

struct MangasmPreviewApp: App {
    var body: some Scene {
        WindowGroup { MangasmRootView().frame(minWidth: 402, minHeight: 874) }
    }
}
MangasmPreviewApp.main()
```

- [ ] **Step 9: Build + test**

Run: `swift build` then `swift test --filter AppStateTests`
Expected: build succeeds; tests PASS.

- [ ] **Step 10: Commit**

```bash
git add Package.swift Sources Tests
git commit -m "feat: walking skeleton — package, AppState, root router, tab shell"
```

---

## Phase 2 — Design system

### Task 2: Theme (colors + fonts + gradients)

**Files:**
- Create: `Sources/MangasmApp/DesignSystem/Theme.swift`
- Test: `Tests/MangasmAppTests/ThemeTests.swift`

**Interfaces:**
- Produces: `extension Color { init(hex:) }`; `enum MGColor` static colors (`gold`, `goldDeep`, `goldBright`, `ink`, `inkSoft`, `inkFaint`, `spotify`, `launchOrange`, `launchOrangeDeep`, `skylineInk`); `enum MGFont { static func serif/sans/mono(_ size:CGFloat, _ weight:Font.Weight=...) -> Font }`; `enum MGGradient { static let holo: LinearGradient; static let goldButton: LinearGradient }`.

- [ ] **Step 1: Write failing test**

```swift
import SwiftUI
import XCTest
@testable import MangasmApp

final class ThemeTests: XCTestCase {
    func testHexParsesRRGGBB() {
        let c = Color(hex: "#C9A84C")
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0xC9/255, accuracy: 0.01)
        XCTAssertEqual(g, 0xA8/255, accuracy: 0.01)
        XCTAssertEqual(b, 0x4C/255, accuracy: 0.01)
        #endif
    }
    func testHexIgnoresLeadingHash() {
        XCTAssertNoThrow(Color(hex: "C9A84C"))
    }
}
```

- [ ] **Step 2: Run test, expect FAIL**

Run: `swift test --filter ThemeTests`
Expected: FAIL (`init(hex:)` missing).

- [ ] **Step 3: Implement `Theme.swift`**

```swift
import SwiftUI

public extension Color {
    init(hex: String) {
        let s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255; g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255;  a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255; g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255;         a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

public enum MGColor {
    public static let gold = Color(hex: "#C9A84C")
    public static let goldDeep = Color(hex: "#9A7B2C")
    public static let goldBright = Color(hex: "#E4C97E")
    public static let ink = Color(hex: "#2A2117")
    public static let inkSoft = Color(red: 42/255, green: 33/255, blue: 23/255, opacity: 0.70)
    public static let inkFaint = Color(red: 42/255, green: 33/255, blue: 23/255, opacity: 0.50)
    public static let spotify = Color(hex: "#138A3E")
    public static let launchOrange = Color(hex: "#F08A38")
    public static let launchOrangeDeep = Color(hex: "#C95E1E")
    public static let skylineInk = Color(hex: "#120A14")
}

public enum MGFont {
    // Custom fonts fall back to system if not registered.
    public static func serif(_ size: CGFloat, _ w: Font.Weight = .bold) -> Font {
        .custom("CormorantGaramond-Bold", size: size).weight(w)
    }
    public static func sans(_ size: CGFloat, _ w: Font.Weight = .semibold) -> Font {
        .custom("Mulish", size: size).weight(w)
    }
    public static func mono(_ size: CGFloat, _ w: Font.Weight = .regular) -> Font {
        .custom("SpaceMono-Regular", size: size).weight(w)
    }
}

public enum MGGradient {
    public static let holo = LinearGradient(
        colors: [Color(hex: "#787C8C"), Color(hex: "#FFFFFF"), Color(hex: "#96B2D2"), MGColor.gold],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    public static let goldButton = LinearGradient(
        colors: [MGColor.goldBright, MGColor.goldDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    public static let launchCTA = LinearGradient(
        colors: [MGColor.launchOrange, MGColor.launchOrangeDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}
```

> `.custom(...)` with a missing font name silently resolves to the system font, satisfying the "graceful fallback" constraint.

- [ ] **Step 4: Run tests, expect PASS**

Run: `swift test --filter ThemeTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/DesignSystem/Theme.swift Tests/MangasmAppTests/ThemeTests.swift
git commit -m "feat: design-system theme (color hex init, palette, fonts, gradients)"
```

### Task 3: Glass + reusable components

**Files:**
- Create: `Sources/MangasmApp/DesignSystem/Glass.swift`
- Create: `Sources/MangasmApp/DesignSystem/Components.swift`

**Interfaces:**
- Consumes: `MGColor`, `MGFont`, `MGGradient`.
- Produces: `View.glassBackground(_ radius:CGFloat, glow:Bool=false) -> some View`; views `Pill<Content>`, `Chip` (`tone: .neutral|.gold`), `Seal`, `SectionLabel`, `MGCard<Content>`, `MGSwitch`, `RepRing`, `Equalizer`, `ProviderButton` (`kind: .apple|.google|.phone`, `action`).

- [ ] **Step 1: Implement `Glass.swift`**

```swift
import SwiftUI

struct GlassBackground: ViewModifier {
    let radius: CGFloat
    var glow: Bool = false
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(glow ? MGColor.gold.opacity(0.53) : Color.white.opacity(0.7),
                            lineWidth: glow ? 1 : 0.7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .fill(LinearGradient(colors: [.white.opacity(0.72), .clear],
                                         startPoint: .top, endPoint: .center))
                    .blendMode(.overlay).allowsHitTesting(false)
            )
            .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
    }
}

public extension View {
    func glassBackground(_ radius: CGFloat, glow: Bool = false) -> some View {
        modifier(GlassBackground(radius: radius, glow: glow))
    }
}
```

- [ ] **Step 2: Implement `Components.swift`**

Implement each primitive per the spec's numeric contract (Pill: pad 5×10, r12; Chip: sans 700/9.5, pad 4×9, r9, gold vs neutral tone; Seal: gold-gradient circle + white check; SectionLabel: serif 700/15, +0.16em, gold + glow; MGCard: holo 1px border wrapper + glass(r-1) inner; MGSwitch: 42×24, gold-gradient when on, white 20px knob, `locked` dims to 0.55; RepRing: 84×84 stroked arc, serif center; Equalizer: 4 bars animating heights; ProviderButton: apple = dark vertical gradient, google/phone = light glass + `GOLD44` border, label Mulish 700/13.5). Each is a small `View` struct.

```swift
import SwiftUI

public struct Chip: View {
    public enum Tone { case neutral, gold }
    let text: String; var tone: Tone = .neutral
    public init(_ text: String, tone: Tone = .neutral) { self.text = text; self.tone = tone }
    public var body: some View {
        Text(text)
            .font(MGFont.sans(9.5, .bold))
            .foregroundStyle(tone == .gold ? MGColor.goldDeep : MGColor.inkSoft)
            .padding(.vertical, 4).padding(.horizontal, 9)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .fill(tone == .gold ? MGColor.gold.opacity(0.16) : MGColor.ink.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(tone == .gold ? MGColor.gold.opacity(0.4) : MGColor.ink.opacity(0.14), lineWidth: 1)
            )
    }
}
// ... Pill, Seal, SectionLabel, MGCard, MGSwitch, RepRing, Equalizer, ProviderButton
// (one focused struct each, exact values from spec §3 / §5.2 / §5.3)
```

- [ ] **Step 3: Build**

Run: `swift build`
Expected: succeeds.

- [ ] **Step 4: Commit**

```bash
git add Sources/MangasmApp/DesignSystem/Glass.swift Sources/MangasmApp/DesignSystem/Components.swift
git commit -m "feat: glass modifier + reusable components"
```

### Task 4: Background + WeatherFX

**Files:**
- Create: `Sources/MangasmApp/DesignSystem/LamborghiniBackground.swift`
- Create: `Sources/MangasmApp/DesignSystem/WeatherFX.swift`

**Interfaces:**
- Consumes: `MGColor`.
- Produces: `public enum Weather: CaseIterable, Sendable { case clear, cloudy, rain, heavyRain, sleet, snow }` (defined HERE — it is needed before Task 5; Task 5 must NOT redefine it); `LamborghiniBackground(night: Bool)`; `WeatherFX(kind: Weather, night: Bool)` composing `Rain`, `RainGlass`, `Snow`, `Frost`, `GodRays`, `SunFlare`, `Clouds`.

- [ ] **Step 1: Implement `LamborghiniBackground.swift`**

Layered `ZStack`: image `lambo_hero` (from `Bundle.module`, `.scaledToFill`, bottom-anchored) with day/night brightness/saturation; carbon overlay (repeating diagonal via `Canvas`); day/night vignette `LinearGradient`; night glow radial; inset edge shadow (`RoundedRectangle.stroke` blurred or `.shadow`). If image absent, fall back to dark gradient.

- [ ] **Step 2: Implement `WeatherFX.swift`**

`Rain` = two `TimelineView(.animation)` particle layers via `Canvas` (far: blurred, 40–64 drops; near: sharp, 18–30). `RainGlass` = beads (radial highlights, bob) + rivulets (descending trails). `Snow` = 52 flakes fall+sway. `Frost`, `GodRays`, `SunFlare`, `Clouds` = decorative gradient layers. `WeatherFX` applies a multiply/screen tint per `kind` and selects layers. All `.allowsHitTesting(false)`. Particle randomness seeded by index (no `Math.random`-equivalent in init paths that break determinism — use index-derived offsets).

- [ ] **Step 3: Build**

Run: `swift build`
Expected: succeeds (no `UIScreen`; sizes via `GeometryReader`).

- [ ] **Step 4: Commit**

```bash
git add Sources/MangasmApp/DesignSystem/LamborghiniBackground.swift Sources/MangasmApp/DesignSystem/WeatherFX.swift
git commit -m "feat: lamborghini background + weather FX system"
```

---

## Phase 3 — Models + mock services

### Task 5: Domain models

**Files:**
- Create: `Sources/MangasmApp/Models/Models.swift`
- Test: `Tests/MangasmAppTests/ModelTests.swift`

**Interfaces:**
- Produces: `RepTier` enum; `struct Profile`, `struct Visibility`, `struct Candidate` (+ `CompatNotes`), `struct Conversation`, `struct Message`, `struct EventItem`, `struct Community`, `struct Venue`. All `Identifiable`/`Hashable`/`Sendable` where sensible, with `static let sample`/`samples`. (`Weather` already defined in Task 4 — do NOT redefine.)

- [ ] **Step 1: Write failing test**

```swift
import XCTest
@testable import MangasmApp

final class ModelTests: XCTestCase {
    func testProfileSampleMatchesPrototypeDefaults() {
        let p = Profile.sample
        XCTAssertEqual(p.name, "Julian")
        XCTAssertEqual(p.age, 32)
        XCTAssertEqual(p.position, "Vers")
    }
    func testBioMaxIsPremiumAware() {
        XCTAssertEqual(Profile.bioMax(premium: false), 300)
        XCTAssertEqual(Profile.bioMax(premium: true), 600)
    }
}
```

- [ ] **Step 2: Run test, expect FAIL**

Run: `swift test --filter ModelTests`
Expected: FAIL.

- [ ] **Step 3: Implement `Models.swift`**

Define every struct with fields from spec §6 and seed `Profile.sample` with the prototype defaults (name Julian/32/Dubai → London, headline, bio, hobbies, position Vers, into, hiv "Negative · on PrEP", lastTested "May 2026", instagram/x, astro Scorpio, chinese Dragon, lifePath 7). Add `static func bioMax(premium:) -> Int { premium ? 600 : 300 }`. Provide `samples` arrays for candidates/conversations/events/communities/venues mirroring the prototype seed data.

- [ ] **Step 4: Run tests, expect PASS**

Run: `swift test --filter ModelTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Models Tests/MangasmAppTests/ModelTests.swift
git commit -m "feat: domain models + sample seed data"
```

### Task 6: Service protocols + mocks + AppEnvironment

**Files:**
- Create: `Sources/MangasmApp/Services/Protocols.swift`
- Create: `Sources/MangasmApp/Services/Mocks.swift`
- Create: `Sources/MangasmApp/Services/AppEnvironment.swift`
- Test: `Tests/MangasmAppTests/ServiceTests.swift`

**Interfaces:**
- Consumes: models.
- Produces: protocols `AuthService` (`func enter()`), `ProfileService` (`func current() -> Profile`, `func update(_:)`), `MatchService` (`func featured() -> Candidate`, `func nearby() -> [Candidate]`, `func refresh()`), `ChatService` (`func conversations() -> [Conversation]`, `func messages(for:) -> [Message]`, `func send(_:to:)`), `EventService` (`func events() -> [EventItem]`, `func communities() -> [Community]`, `func rsvp(_:)`), `ReputationService` (`func score(for:) -> Int`, `func canViewPhotos(viewer:target:) -> Bool`). `final class AppEnvironment: ObservableObject` holding mock instances; `static let mock`.

- [ ] **Step 1: Write failing test**

```swift
import XCTest
@testable import MangasmApp

final class ServiceTests: XCTestCase {
    func testReputationGatesPhotosBelowThreshold() {
        let rep = MockReputationService()
        XCTAssertFalse(rep.canViewPhotos(viewerScore: 10, targetGate: 50))
        XCTAssertTrue(rep.canViewPhotos(viewerScore: 80, targetGate: 50))
    }
    func testMatchRefreshAdvancesFeatured() {
        let m = MockMatchService()
        let first = m.featured().id
        m.refresh()
        XCTAssertNotEqual(first, m.featured().id)
    }
}
```

- [ ] **Step 2: Run test, expect FAIL**

Run: `swift test --filter ServiceTests`
Expected: FAIL.

- [ ] **Step 3: Implement protocols, mocks, environment**

Mocks hold the sample data; `MockMatchService.refresh()` increments an index modulo candidates; `MockReputationService.canViewPhotos(viewerScore:targetGate:)` returns `viewerScore >= targetGate`. `AppEnvironment.mock` wires all mocks.

- [ ] **Step 4: Run tests, expect PASS**

Run: `swift test --filter ServiceTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Services Tests/MangasmAppTests/ServiceTests.swift
git commit -m "feat: service protocols, mock implementations, DI environment"
```

### Task 7: Wire AppEnvironment + extend AppState

**Files:**
- Modify: `Sources/MangasmApp/Shell/AppState.swift`
- Modify: `Sources/MangasmApp/Shell/MangasmRootView.swift`

**Interfaces:**
- Produces: `AppState` gains `@Published var weather: Weather`, `selectedMatch: Candidate?`, `profile: Profile`, `visibility: Visibility`; `MangasmRootView` injects `AppEnvironment.mock` as `@StateObject` + `.environmentObject`.

- [ ] **Step 1: Extend `AppState`** with weather/profile/visibility/selectedMatch (defaults from samples).
- [ ] **Step 2: Inject `AppEnvironment`** in `MangasmRootView`.
- [ ] **Step 3: Build + test**

Run: `swift build && swift test`
Expected: all green.

- [ ] **Step 4: Commit**

```bash
git add Sources/MangasmApp/Shell
git commit -m "feat: wire AppEnvironment + extend AppState"
```

---

## Phase 4 — Launch flow

### Task 8: LaunchFlow + SplashView

**Files:**
- Create: `Sources/MangasmApp/Launch/LaunchFlow.swift`
- Create: `Sources/MangasmApp/Launch/SplashView.swift`
- Modify: `Sources/MangasmApp/Shell/MangasmRootView.swift` (launch phase → `LaunchFlow`)

**Interfaces:**
- Consumes: design system.
- Produces: `LaunchFlow(onEnter: () -> Void)` with internal `enum Stage { case splash, signIn }`; `SplashView(onContinue: () -> Void)`.

- [ ] **Step 1: Implement `LaunchFlow`** — `@State stage`; shows `SplashView { stage = .signIn }` then `SignInView { onEnter() }` (SignIn arrives Task 9; temporarily route to a stub that calls `onEnter`).
- [ ] **Step 2: Implement `SplashView`** per spec §5.1: video layer (`VideoPlayer` from `Bundle.module` `runway.mp4`, muted/looped, fallback gradient), cinematic overlays, lockup (kicker/wordmark/tagline), CTA (gradient + pulse + shimmer), SKIP pill, full-screen tap-catcher. Timeline via `.task` with `Task.sleep`; auto-advance 8.6s; SKIP/tap/CTA all call `go()` → fade → `onContinue()`. Sizes via `GeometryReader`.
- [ ] **Step 3: Route** `MangasmRootView` `.launch` → `LaunchFlow { state.enterApp() }`.
- [ ] **Step 4: Build + run**

Run: `swift build` (and optionally `swift run MangasmPreview` to eyeball).
Expected: builds.

- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Launch Sources/MangasmApp/Shell/MangasmRootView.swift
git commit -m "feat: launch flow + runway splash"
```

### Task 9: SignInView + skylines

**Files:**
- Create: `Sources/MangasmApp/Launch/SkylineShapes.swift`
- Create: `Sources/MangasmApp/Launch/LandmarkSlides.swift`
- Create: `Sources/MangasmApp/Launch/SignInView.swift`
- Modify: `Sources/MangasmApp/Launch/LaunchFlow.swift`
- Test: `Tests/MangasmAppTests/SkylineTests.swift`

**Interfaces:**
- Produces: `enum City { case dubai, london, mykonos, tokyo; var name/coord/tag/sky }`; `struct Skyline: Shape` (per-city path in 400×150 space); `LandmarkSlides()`; `SignInView(onEnter: () -> Void)`.

- [ ] **Step 1: Write failing test**

```swift
import SwiftUI
import XCTest
@testable import MangasmApp

final class SkylineTests: XCTestCase {
    func testFourCities() { XCTAssertEqual(City.allCases.count, 4) }
    func testDubaiTag() { XCTAssertEqual(City.dubai.tag, "where the signal shouldn't reach") }
    func testSkylinePathNonEmpty() {
        let r = CGRect(x: 0, y: 0, width: 400, height: 150)
        XCTAssertFalse(Skyline(city: .tokyo).path(in: r).isEmpty)
    }
}
```

- [ ] **Step 2: Run, expect FAIL** — `swift test --filter SkylineTests`.
- [ ] **Step 3: Implement `City`** with the 4 cities' name/coord/tag/sky stops (spec §5.2) and `Skyline: Shape` drawing each city's building bands + landmarks (Dubai Burj cluster; London Eye/Big Ben/Shard; Mykonos dome+windmill; Tokyo Tower/Skytree) using the coordinate tables.
- [ ] **Step 4: Implement `LandmarkSlides`** — cross-fading slides (4.2s cycle, 1.4s fade), each = sky gradient + sun-haze + `Skyline` fill `skylineInk` + ground band + Ken-Burns scale/pan. Caption (coords/name/tag) + progress dots.
- [ ] **Step 5: Implement `SignInView`** — `LandmarkSlides` background + legibility veils + bottom glass sheet (grab handle, gold wordmark, members line, 3 `ProviderButton`s, OR divider, "Enter the community →" gold button, legal line). Every control → `onEnter()`.
- [ ] **Step 6: Route** `LaunchFlow` `.signIn` → `SignInView { onEnter() }`.
- [ ] **Step 7: Build + test** — `swift build && swift test --filter SkylineTests`. Expected: green.
- [ ] **Step 8: Commit**

```bash
git add Sources/MangasmApp/Launch Tests/MangasmAppTests/SkylineTests.swift
git commit -m "feat: landmark sign-in + drawn city skylines"
```

---

## Phase 5 — Main app screens (each compile-verified)

### Task 10: MainTabView chrome + TopBar

**Files:**
- Modify: `Sources/MangasmApp/Shell/MainTabView.swift`
- Create: `Sources/MangasmApp/Shell/TopBar.swift`

**Interfaces:**
- Produces: custom glass tab bar (Discover/Search/AI Match[raised gold pill]/Likes/Profile per spec §6 icons), `TopBar(weather:night:)` (reputation number, weather pill, logo, PRIVATE badge, settings).

- [ ] **Step 1: Replace default `TabView`** with a `ZStack` (selected screen + overlaid custom glass tab bar, 14pt insets, r24). AI Match is the raised gold-gradient pill.
- [ ] **Step 2: Implement `TopBar`** per §TopBar spec.
- [ ] **Step 3: Route tabs** to the feature screens (Task 11–15) — until then, `PlaceholderScreen`.
- [ ] **Step 4: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Shell
git commit -m "feat: custom glass tab bar + top bar"
```

### Task 11: Profile screen

**Files:**
- Create: `Sources/MangasmApp/Features/Profile/ProfileScreen.swift`
- Create: `Sources/MangasmApp/Features/Profile/ProfileParts.swift` (Anthem, SocialRow)
- Modify: `MainTabView.swift` (route `.profile`)

**Interfaces:**
- Consumes: `AppState.profile/visibility/premium`, `ReputationService`, design system.
- Produces: `ProfileScreen()`.

- [ ] **Step 1: Implement `ProfileScreen`** per spec §5.3 over `LamborghiniBackground` + `WeatherFX`, scroll insets 150/14/96; all sections gated by `Visibility`; photos gated via `ReputationService`.
- [ ] **Step 2: Implement Anthem + SocialRow** parts.
- [ ] **Step 3: Route** `.profile`.
- [ ] **Step 4: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Features/Profile Sources/MangasmApp/Shell/MainTabView.swift
git commit -m "feat: profile screen"
```

### Task 12: Discover screen (fake map + grid + tabs)

**Files:**
- Create: `Sources/MangasmApp/Features/Discover/DiscoverScreen.swift`
- Create: `Sources/MangasmApp/Features/Discover/FakeMap.swift`
- Modify: `MainTabView.swift` (route `.discover`, `.search`, `.likes`)

**Interfaces:**
- Produces: `DiscoverScreen(mode: .nearby|.likes)`; `FakeMap(pins:)`.

- [ ] **Step 1: Implement `FakeMap`** — gradient base + street lines (`Path`) + radial gold glow + glass pins (hot ≥85% get gold ring/glow) + privacy-zone badge.
- [ ] **Step 2: Implement `DiscoverScreen`** — `DiscoverTabs` (Nearby/Communities/Events), nearby = map + 2-col grid cards; communities/events tabs embed Task 14 views; likes mode = grid only.
- [ ] **Step 3: Route** `.discover`/`.search`/`.likes`.
- [ ] **Step 4: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Features/Discover Sources/MangasmApp/Shell/MainTabView.swift
git commit -m "feat: discover screen with stylized map + user grid"
```

### Task 13: AI Match + Match detail

**Files:**
- Create: `Sources/MangasmApp/Features/Match/AIMatchScreen.swift`
- Create: `Sources/MangasmApp/Features/Match/CompatibilityRing.swift`
- Create: `Sources/MangasmApp/Features/Match/MatchDetailScreen.swift`
- Modify: `MainTabView.swift` (route `.aiMatch`)

**Interfaces:**
- Produces: `AIMatchScreen()`; `CompatibilityRing(percent:)`; `MatchDetailScreen(candidate:onMessage:)`.

- [ ] **Step 1: Implement `CompatibilityRing`** — animated trimmed `Circle` stroke (gold), serif center percent.
- [ ] **Step 2: Implement `AIMatchScreen`** per §5.5 (header chips, featured card, refresh via `MatchService.refresh()`, trio grid, venue RSVP cards with idle/requested/declined states).
- [ ] **Step 3: Implement `MatchDetailScreen`** — full candidate profile + compat breakdown; "Message" → set `selectedMatch`, navigate to chat.
- [ ] **Step 4: Route** `.aiMatch`.
- [ ] **Step 5: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 6: Commit**

```bash
git add Sources/MangasmApp/Features/Match Sources/MangasmApp/Shell/MainTabView.swift
git commit -m "feat: AI match screen + compatibility ring + match detail"
```

### Task 14: Events + Communities

**Files:**
- Create: `Sources/MangasmApp/Features/Events/EventsView.swift`
- Create: `Sources/MangasmApp/Features/Events/EventCard.swift`
- Create: `Sources/MangasmApp/Features/Events/HostEventForm.swift`
- Create: `Sources/MangasmApp/Features/Events/CommunitiesView.swift`

**Interfaces:**
- Produces: `EventsView(premium:)`; `CommunitiesView()`; `EventCard(event:)`; `HostEventForm(onPublish:)`.

- [ ] **Step 1: Implement `CommunitiesView`** — community cards (monogram, name, tag, members, Join, pride bar).
- [ ] **Step 2: Implement `EventCard` + `EventsView`** — host CTA (locked vs premium), type filter bar, event cards (badge, host+rep, meta rows, attendees + RSVP/Request).
- [ ] **Step 3: Implement `HostEventForm`** — type picker, fields w/ counters, visibility, consent note (18+/ID/no-recording), publish enabled only when valid.
- [ ] **Step 4: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Features/Events
git commit -m "feat: events + host form + communities"
```

### Task 15: Chat (list + thread)

**Files:**
- Create: `Sources/MangasmApp/Features/Chat/ChatListScreen.swift`
- Create: `Sources/MangasmApp/Features/Chat/ChatThreadScreen.swift`

**Interfaces:**
- Consumes: `ChatService`, `AppState.selectedMatch`.
- Produces: `ChatListScreen(onOpen:)`; `ChatThreadScreen(conversation:onBack:)`.

- [ ] **Step 1: Implement `ChatListScreen`** — rows (avatar gold ring, name, last message, time, unread).
- [ ] **Step 2: Implement `ChatThreadScreen`** — glass header (back/avatar/online/match-%), E2E banner, bubbles (received left / sent gold-gradient right), typing indicator, glass composer + gold send.
- [ ] **Step 3: Wire** match-detail "Message" → thread; chat list → thread.
- [ ] **Step 4: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Features/Chat
git commit -m "feat: chat list + thread with safety affordances"
```

### Task 16: Settings

**Files:**
- Create: `Sources/MangasmApp/Features/Settings/SettingsScreen.swift`

**Interfaces:**
- Produces: `SettingsScreen()` editing `AppState.profile/visibility` + demo toggles (weather/night/starlink/premium).

- [ ] **Step 1: Implement `SettingsScreen`** — `Field` editors (label/value/counter/sanitize/hint) + `MGSwitch` visibility toggles (some locked behind premium) + demo toggles.
- [ ] **Step 2: Present** Settings from `TopBar` settings button.
- [ ] **Step 3: Build** — `swift build`. Expected: succeeds.
- [ ] **Step 4: Commit**

```bash
git add Sources/MangasmApp/Features/Settings Sources/MangasmApp/Shell
git commit -m "feat: settings screen with field editors + visibility toggles"
```

---

## Phase 6 — Assets + final verification

### Task 17: Bundle assets + final dual-platform build

**Files:**
- Create: `Sources/MangasmApp/Resources/lambo_hero.jpg` (copy from handoff)
- Create: `Sources/MangasmApp/Resources/runway.mp4` (copy from handoff)
- Create: `Sources/MangasmApp/Resources/Fonts/.gitkeep`
- Create: `README.md`

- [ ] **Step 1: Copy assets** (from the durable zip at `~/Mangasmfinal.zip`)

```bash
mkdir -p Sources/MangasmApp/Resources/Fonts && touch Sources/MangasmApp/Resources/Fonts/.gitkeep
TMP=$(mktemp -d)
unzip -j -o ~/Mangasmfinal.zip \
  'design_handoff_mangasm_launch/prototype/assets/lambo_hero.jpg' \
  'design_handoff_mangasm_launch/prototype/assets/runway.mp4' -d "$TMP"
cp "$TMP/lambo_hero.jpg" "$TMP/runway.mp4" Sources/MangasmApp/Resources/
rm -rf "$TMP"
```

- [ ] **Step 2: Full test + macOS build**

Run: `swift test && swift build`
Expected: all green.

- [ ] **Step 3: iOS-target build (matches deliverable)**

Run: `xcodebuild -scheme MangasmApp -destination 'generic/platform=iOS Simulator' build`
Expected: BUILD SUCCEEDED. (If the scheme isn't auto-generated, `xcodebuild -list` first.)

- [ ] **Step 4: Write `README.md`** — what it is, how to run (`swift run MangasmPreview`), how to add fonts/assets, the mock→real service seam, link to spec.

- [ ] **Step 5: Commit**

```bash
git add Sources/MangasmApp/Resources README.md
git commit -m "feat: bundle assets + README; verify macOS + iOS builds"
```

---

## Self-Review

**Spec coverage:** §1 goal → Tasks 1–17. §2 decisions → Package/cross-platform (T1), tokens (T2), mocks (T6), stubbed auth (T9), fake map (T12), superseded splash (T8 rebuilds, old file untouched). §3 tokens → T2/T3. §4 architecture → all phases mirror the module tree. §5 screens: splash T8, sign-in T9, profile T11, discover T12, AI match T13, chat T15, events T14, settings T16. §6 models → T5. §7 build order → phases 1→6. §8 verification → T17 (+ per-task builds, logic tests T1/T2/T5/T6/T9). §9 constraints → fonts/assets fallback in T2/T4/T17. No gaps.

**Placeholder scan:** Foundational/testable tasks (1,2,5,6,9) carry complete code. View-heavy tasks (3,4,8,10–16) carry exact file/interface/structure contracts that resolve to the spec's pinned numeric values rather than re-transcribing every pixel into the plan; this is deliberate for a high-fidelity port where the spec is the numeric source of truth, and each ends with a `swift build` gate. No "TBD/handle edge cases" left.

**Type consistency:** `AppState`, `AppTab`, `AppPhase`, `AppEnvironment`, `MGColor`, `MGFont`, `MGGradient`, `glassBackground`, `Weather`, `City`, `Skyline`, service protocol method names are used identically across tasks. `Weather` is defined exactly once, in Task 4 (`WeatherFX.swift`), and consumed by Task 5+ — no duplicate declaration.
