# Mangasm — SwiftUI Front-End

Mangasm is a safety-first gay dating app. This repository is the **SwiftUI front-end package**, wired to a mock service layer. Every auth control, service call, and data fetch goes through a protocol seam so the mock can be replaced with a real backend without touching the UI.

## What this repo is

- A multiplatform Swift Package (`swift-tools-version: 6.0`).
- Library target `MangasmApp` — all screens, design system, models, and service protocols.
- Executable target `MangasmPreview` — a macOS `@main` entry point so `swift run` opens a live preview window.
- Test target `MangasmAppTests` — unit tests for `AppState`, `Theme`, `Models`, `Services`, and `Skylines`.

The iOS app target is the deliverable; the macOS preview target exists so every engineer can run and inspect every screen without a device or simulator.

## Quick start

### macOS preview window

```bash
swift run MangasmPreview
```

Opens a resizable window sized to an iPhone canvas (402 × 874). All screens are navigable: splash → sign-in → tabs (Discover / Search / AI Match / Likes / Profile) with a Settings sheet reachable from the top bar.

### Open in Xcode / build for iOS Simulator

```bash
open Package.swift
```

Select the `MangasmApp` scheme, choose any iOS Simulator, and run. Alternatively:

```bash
xcodebuild -scheme MangasmApp -destination 'generic/platform=iOS Simulator' build
```

### Run tests

```bash
swift test
```

Expected: 27 tests, 0 failures across `AppStateTests`, `ModelTests`, `ServiceTests`, `SkylineTests`, `ThemeTests`.

## Architecture

```
Sources/
  MangasmApp/
    DesignSystem/     — Theme.swift, Glass.swift, Components.swift,
                        LamborghiniBackground.swift, WeatherFX.swift
    Models/           — Models.swift  (Profile, Candidate, Conversation, …)
    Services/         — Protocols.swift, Mocks.swift, AppEnvironment.swift
    Shell/            — AppState.swift, MangasmRootView.swift,
                        MainTabView.swift, TopBar.swift
    Launch/           — LaunchFlow.swift, SplashView.swift,
                        SignInView.swift, SkylineShapes.swift,
                        LandmarkSlides.swift
    Features/
      Profile/        — ProfileScreen.swift, ProfileParts.swift
      Discover/       — DiscoverScreen.swift, FakeMap.swift
      Match/          — AIMatchScreen.swift, CompatibilityRing.swift,
                        MatchDetailScreen.swift
      Events/         — EventsView.swift, EventCard.swift,
                        CommunitiesView.swift, HostEventForm.swift
      Chat/           — ChatListScreen.swift, ChatThreadScreen.swift
      Settings/       — SettingsScreen.swift
    Resources/        — lambo_hero.jpg, runway.mp4, Fonts/
  MangasmPreview/
    main.swift
Tests/
  MangasmAppTests/
```

### Key types

| Type | Role |
|------|------|
| `AppState` | `@EnvironmentObject` — phase (launch/app), tab, weather, profile, selectedMatch |
| `AppEnvironment` | `@EnvironmentObject` — DI container holding service protocol instances |
| `MGColor` / `MGFont` / `MGGradient` | Design-system tokens (single source of truth) |
| `MangasmRootView` | Root router: launch phase → `LaunchFlow`; app phase → `MainTabView` |

### Routing flow

```
MangasmRootView
  └── LaunchFlow         (AppPhase.launch)
        ├── SplashView   (runway video + CTA)
        └── SignInView   (landmark slides + auth sheet)
  └── MainTabView        (AppPhase.app)
        ├── DiscoverScreen   (.discover / .search / .likes)
        ├── AIMatchScreen    (.aiMatch)
        ├── ProfileScreen    (.profile)
        ├── ChatListScreen   (modal, opened from match detail)
        └── SettingsScreen   (modal, opened from top bar)
```

## Mock → real service swap

`AppEnvironment` holds instances of the service protocols. The injected mock is `AppEnvironment.mock`. To wire a real backend:

1. Implement the protocols in `Sources/MangasmApp/Services/Protocols.swift`:
   `AuthService`, `ProfileService`, `MatchService`, `ChatService`, `EventService`, `ReputationService`.
2. Replace `AppEnvironment.mock` with an `AppEnvironment` initialised with your real implementations.
3. No view code changes required — screens read from `@EnvironmentObject var env: AppEnvironment`.

## Custom fonts

Drop `.ttf`/`.otf` files into `Sources/MangasmApp/Resources/Fonts/` and rebuild.
`Package.swift` picks them up via `.process("Resources")` and they become available in `Bundle.module`.

See `Sources/MangasmApp/Resources/Fonts/README.md` for the exact file names and download links (all SIL OFL).

Until the files are present, `MGFont` falls back transparently to system `.serif` / default / `.monospaced` — the app never hard-fails on a missing font.

## Production assets

| Asset | Status |
|-------|--------|
| `lambo_hero.jpg` | Bundled — Lamborghini background photo |
| `runway.mp4` | Bundled — splash screen runway video |
| Font `.ttf` files | Not bundled — add from Google Fonts (OFL) |

## Spec and plan

- Design spec: [`docs/superpowers/plans/2026-06-21-mangasm-launch-and-app-design.md`](docs/superpowers/plans/2026-06-21-mangasm-launch-and-app-design.md)
- Implementation plan: [`docs/superpowers/plans/2026-06-21-mangasm-launch-and-app.md`](docs/superpowers/plans/2026-06-21-mangasm-launch-and-app.md)

## Known limitations

- **Mock backend only** — all data is seeded from `Profile.sample`, `Candidate.samples`, etc. No real auth, network calls, or persistence.
- **Placeholder art / fonts** — `lambo_hero.jpg` and `runway.mp4` are the bundled prototype assets. Custom OFL fonts are not included; system fallbacks are active.
- **Map is stylized, not functional** — `FakeMap` renders gradient streets and pinned avatars; it does not use MapKit or real GPS data.
- **Auth controls are visual only** — every provider button and "Enter" control calls `onEnter()` and advances the phase. No real OAuth flow is wired.
- **macOS preview is a dev tool** — `MangasmPreview` is excluded from the iOS product; it exists solely to let engineers run screens on a Mac.
