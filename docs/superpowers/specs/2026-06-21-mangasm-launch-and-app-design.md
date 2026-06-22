# Mangasm — Launch Experience + Full App (SwiftUI / SPM)

**Date:** 2026-06-21
**Status:** Approved design → implementation plan next
**Source of truth:** `design_handoff_mangasm_launch` (hifi prototype, `Mangasmfinal.zip`) + token definitions read directly from `mangasm-fx.jsx` / `mangasm-launch.jsx`.

## 1. Goal

Bootstrap the Mangasm iOS app from an empty repo: a complete, navigable SwiftUI
front-end covering the launch flow (Splash → Sign-In) and the main app
(Profile, Discover, AI Match, Chat, Events, Settings), driven by a mock data
layer behind protocol seams so real Supabase / Stripe / AI-moderation can land
later without view rework.

Mangasm is a **safety-first gay dating app**: reputation, vouches,
reputation-gated photos, consent/safety notes, and E2E-encryption affordances
are first-class UI, not afterthoughts.

## 2. Decisions (locked)

- **Packaging:** multiplatform Swift Package (SPM) at repo root. Compiles via
  `swift build` on the macOS host **and** as an iOS app
  (`xcodebuild -destination 'generic/platform=iOS Simulator'`).
- **Cross-platform first:** use `GeometryReader` etc., never `UIScreen.main`.
  `#if os(iOS)` reserved only for genuinely iOS-only APIs, because
  `swift build` (macOS) does **not** compile `#if os(iOS)` branches.
- **Backend:** in-memory mock services behind protocols. No network this pass.
- **Auth:** Apple / Google / phone buttons are visual; all call `onEnter()`.
- **Map:** Discover NEARBY uses the prototype's stylized fake map (gradient +
  street lines + glass pins). No MapKit.
- **Superseded:** existing `~/Mangasm_RunwaySplash.swift` is a different, older
  aesthetic (Bebas Neue, "M" monogram, orange→teal, "THE COMMUNITY YOU
  DESERVED"). The handoff is declared hifi/final and **wins**. The old file is
  NOT carried into the project; it is a reference draft only.
- **Location:** `/Users/swagger/Mangasm` (currently empty git repo).

## 3. Design tokens (authoritative — from source, not summaries)

Shared gold system (used by both app and launch):

| Token | Hex |
|---|---|
| `GOLD` | `#C9A84C` |
| `GOLD_DEEP` | `#9A7B2C` |
| `GOLD_BRIGHT` | `#E4C97E` |
| `INK` | `#2A2117` |
| `INK_SOFT` | `rgba(42,33,23,0.70)` |
| `INK_FAINT` | `rgba(42,33,23,0.50)` |
| `SPOTIFY` (green) | `#138A3E` |

Launch-only accent:

| Token | Hex |
|---|---|
| `launchOrange` | `#F08A38` |
| `launchOrangeDeep` | `#C95E1E` |

> The README's `mgGold #E8C77E` and several extraction guesses (`#e8c77e`,
> `#FFE4C8`, `#E8BD6A`) are **wrong**; source defines `GOLD = #C9A84C`. Skyline
> silhouette fill is intentionally darker (`#120a14` / `rgba(12,7,16,0.9)`).

Fonts (OFL): **Cormorant Garamond** (serif), **Mulish** (sans), **Space Mono**
(mono). `.ttf` not in hand → register if present in `Resources/Fonts`, else fall
back to system `.serif` / default / `.monospaced`.

Gradients / effects (verbatim):
- `holo` = `linear-gradient(120deg, rgba(120,128,140,.9), rgba(255,255,255,.98) 34%, rgba(150,178,210,.85) 60%, rgba(201,168,76,.85))`
- `goldGlow` = `0 1px 10px rgba(201,168,76,.30), 0 1px 1px rgba(255,255,255,.4)`
- `glass(op)`: base body `linear-gradient(150deg, rgba(238,244,252,o+.015), rgba(200,212,228, max(o-.012,.016)))` where `o=(0.22+op*0.30)*0.12`; backdrop `blur(22px) saturate(150%) brightness(1.04)`; border `0.7px rgba(226,236,250,.55)`; rim `inset 0 1px 0 rgba(255,255,255,.72), inset 0 0 .6px rgba(255,255,255,.5), inset 0 -12px 26px -16px rgba(110,132,164,.4)`; refraction overlay `linear-gradient(108deg, transparent 22%, rgba(201,168,76,.10) 40%, rgba(255,255,255,.16) 52%, rgba(176,205,235,.10) 64%, transparent 80%)` rotated -12°, blur 4px, soft-light.
  - SwiftUI mapping: `.ultraThinMaterial` + bright top stroke + inner-bottom shade gradient + faint diagonal refraction overlay.

## 4. Architecture

```
Package.swift                      platforms [.iOS(.v17), .macOS(.v14)]
Sources/MangasmApp/                library target (all app code)
  DesignSystem/
    Theme.swift                    Palette, gradients, MGFont, glow/shadow consts
    Glass.swift                    glassBackground() modifier, Refraction
    Components.swift               Pill, Chip, Seal, SectionLabel, Card, MGSwitch,
                                   RepRing, Equalizer, ProviderButton(shared)
    LamborghiniBackground.swift    photo plate + carbon + vignette + night glow + inset
    WeatherFX.swift                WeatherFX, Rain(2 layers), RainGlass(beads+rivulets),
                                   Snow, Frost, GodRays, SunFlare, Clouds
  Models/
    Profile.swift, Visibility.swift, Candidate.swift, Conversation.swift,
    Message.swift, Event.swift, Community.swift, Venue.swift,
    Weather.swift (enum), Reputation.swift
  Services/
    Protocols.swift                AuthService, ProfileService, MatchService,
                                   ChatService, EventService, ReputationService
    Mocks/                         Mock* implementations + seed data
    AppEnvironment.swift           DI container of the protocols
  Launch/
    LaunchFlow.swift               stage .splash → .signIn
    SplashView.swift
    SignInView.swift, LandmarkSlides.swift, SkylineShapes.swift
  Features/
    Profile/ProfileScreen.swift (+ Anthem, SocialRow)
    Discover/DiscoverScreen.swift (+ DiscoverTabs, FakeMap, UserGridCard)
    Match/AIMatchScreen.swift (+ CompatibilityRing, VenueCard), MatchDetailScreen.swift
    Chat/ChatListScreen.swift, ChatThreadScreen.swift (bubbles, composer, typing)
    Events/EventsView.swift (+ EventCard, HostEventForm), CommunitiesView.swift
    Settings/SettingsScreen.swift (Field editors, visibility MGSwitches)
  Shell/
    AppState.swift                 ObservableObject: phase, tab, weather, night,
                                   premium, profile, visibility, selectedMatch
    MangasmRootView.swift          phase gate launch/app
    MainTabView.swift (+ TopBar)   tabs: Discover, Search, AI Match, Likes, Profile
Sources/MangasmPreview/main.swift  macOS @main App → `swift run` opens a window
Tests/MangasmAppTests/             models, mock services, reputation gating
Resources/                         runway.mp4, lambo_hero.jpg, Fonts/ (optional)
```

**Data flow:** `AppState` is the single `@EnvironmentObject`; `AppEnvironment`
exposes the service protocols. Views call protocols only. Mock → real swap is a
DI change, no view edits.

## 5. Screen specifications

All numeric/layout/animation values are captured in the extraction notes from
the handoff prototype and are treated as the implementation contract. Summary:

### 5.1 Launch — Splash (`SplashView`)
- z-order: black → runway.mp4 (`scale 1.04`, autoplay/muted/loop, fallback
  gradient if not in bundle) → cinematic grade gradient → radial orange haze
  (screen blend) → inset vignette `0 0 150px 40px rgba(0,0,0,.7)`.
- Lockup (bottom ≈132): kicker `EST. MMXXVI` (mono 9, +0.5em, orange);
  wordmark `Mangasm` (serif 700/60, white, orange glow loop); tagline
  `DARK LUXURY · BROTHERHOOD · NIGHTLIFE` (mono 9.5, +0.42em).
- CTA (bottom 46): gradient `135deg launchOrange→launchOrangeDeep`, serif 700/16
  +0.08em, radius 16, pulse + shimmer; sub `TAP ANYWHERE TO CONTINUE`.
- SKIP glass pill top-right; full-bleed transparent tap-catcher.
- Timeline: kicker .4s → wordmark .7s (glow loop from 1.8s) → tagline 1.5s →
  CTA 3.1s (shimmer 3.6s); auto-advance 8.6s → fade .48s → sign-in.
- Animations: `mglogoIn`, `mgglow`, `mgrise`, `mgctaPulse`, `mgshimmer`
  (exact keyframes in extraction).

### 5.2 Launch — Sign-In (`SignInView` + `LandmarkSlides`)
- 4 cities cross-fading every 4.2s (fade 1.4s), each: 3-stop sky gradient +
  sun-haze radial + SwiftUI-drawn skyline silhouette + reflective ground band +
  Ken-Burns (`mgkb` scale 1.02→1.16, pan -2%, 9s).
  - Dubai `25.20°N·55.27°E` "where the signal shouldn't reach" `#241a36→#6e3550→#e0894a`
  - London `51.50°N·0.12°W` "after-hours, members only" `#161f3c→#3c3a64→#bf6a7e`
  - Mykonos `37.44°N·25.32°E` "white walls, gold nights" `#102634→#2f6f7c→#e7bd6e`
  - Tokyo `35.67°N·139.65°E` "neon, velvet & rain" `#191334→#5a2a4c→#d4585a`
- Skylines drawn as `Shape`/`Canvas` in a 400×150 space (per-city building
  bands + landmarks: Burj cluster, London Eye/Big Ben/Shard, Mykonos
  dome+windmill, Tokyo Tower/Skytree — coordinates in extraction).
- Caption (top 92): coords (mono +0.34em) · city (serif 40) · italic tag (15) ·
  progress dots (active = 18px gold pill, glow).
- Sheet (bottom, glass, radius 30): grab handle · `Mangasm` gold wordmark ·
  `BY INVITATION · MEMBERS ONLY` · 3 provider buttons (Apple dark; Google/phone
  light glass) · OR divider · `Enter the community →` gold button · legal line
  with COMMUNITY GUIDELINES / PRIVACY links. All controls → `onEnter()`.

### 5.3 Profile (`ProfileScreen`)
Vouches + AI-match strip; italic gold headline; glass profile card (72px avatar
w/ gold ring + Spotify badge, name+age+Seal, location, position/Elite/MGC
chips); bio + counter (300 free / 600 M+); HOBBIES chips; INTO chips (M+ only);
HIV status row (green); socials (IG/X); anthem (Spotify-style w/ equalizer);
E2E + privacy-zone footer; reputation-gated PHOTOS grid + add. Scroll insets
150/14/96. Fields gated by `Visibility`.

### 5.4 Discover (`DiscoverScreen`)
`DiscoverTabs` = Nearby / Communities / Events. Nearby: section label +
online count; stylized fake map (gradient + street SVG lines + radial gold glow
+ glass pins, hot pins ≥85% match get gold ring/glow) + privacy-zone badge;
2-col user grid (image, match-% glass badge, name/distance/position overlay).
Communities tab → `CommunitiesView`; Events tab → `EventsView`. Likes view
reuses grid with "admirers", no map.

### 5.5 AI Match (`AIMatchScreen` + `MatchDetailScreen`)
Header (lamp + AI MATCHMAKING + factor chips); featured "TODAY'S TOP MATCH"
card (photo, name/age/distance, animated `CompatibilityRing` stroke-dashoffset,
shared chips, astrology/life-path/zodiac breakdown rows, VIEW FULL PROFILE);
"Request 3 new suggestions" refresh; trio grid; "RSVP A FIRST DATE" venue cards
(idle → RSVP/Message/Decline → requested/declined states). Detail screen opens
on tap; `onMessage` → Chat.

### 5.6 Chat (`ChatListScreen` + `ChatThreadScreen`)
List rows: avatar (gold ring), name, last message, time, unread badge. Thread:
glass header (back, avatar, online, match-% pill), E2E banner, bubbles
(received cream-white left tail; sent gold-gradient right tail) with `mgpop` +
float, typing indicator (3 pulsing dots), glass composer + gold send button.

### 5.7 Events (`EventsView` + `HostEventForm`)
Communities cards (monogram, name, tag, members, Join, pride bar). Events:
host CTA (locked → "Unlock M+ $9.99/mo"; premium → "Host an Event"); type
filter bar; event cards (type icon, title, approval/open badge, host+rep,
description, time/location rows, attendees + RSVP/Request). Host form (M+):
type picker, fields (title/desc/date/capacity/place/area w/ counters),
visibility, **consent note** (18+, ID at door, no recording), publish (enabled
only when valid).

### 5.8 Settings (`SettingsScreen`)
Editable profile `Field`s (label, value, counter, sanitize, hint) + visibility
`MGSwitch`es (some locked behind M+), weather/night/starlink demo toggles,
premium toggle.

## 6. Models (mock seed mirrors prototype defaults)

`Profile` (name, age, location, headline, bio, hobbies, position, into, hiv,
lastTested, instagram, x, astro, chinese, lifePath, avatar, photos, vouches,
reputation, repTier, aiMatch, premium). `Visibility` (per-field bools).
`Candidate`/`Match` (+ shared, notes{astro,num,chin}). `Conversation`/`Message`.
`Event` (type, title, desc, host, rep, dateTime, venue, area, capacity,
attendees, privacy, rsvpStatus). `Community`. `Venue`. `Weather` enum
(clear/cloudy/rain/heavyRain/sleet/snow). `RepTier`.

## 7. Build order (walking skeleton first)

1. `Package.swift` + `AppState` + `MangasmRootView` + empty `MainTabView` +
   placeholder screens + `MangasmPreview` → **builds & runs**.
2. DesignSystem (Theme, Glass, Components, Background, WeatherFX).
3. Models + Mock services + AppEnvironment.
4. Launch (Splash, then Sign-In + skylines).
5. Features one at a time, each `swift build`-clean: Profile → Discover →
   AI Match → Chat → Events → Settings.
6. Tests for models / mock services / reputation gating.

## 8. Verification

- `swift build` clean (macOS host) after each module.
- One `xcodebuild -scheme MangasmApp -destination 'generic/platform=iOS Simulator' build`
  to confirm the iOS target compiles (matches the deliverable).
- `swift test` for the logic targets.
- Status reports state **which** target was verified — no "it compiles" without
  saying for which platform.

## 9. Known constraints / non-goals

- No real networking, persistence, payments, or push this pass.
- Fonts and high-res licensed photography are placeholders (graceful fallback).
- Skyline art and `lambo_hero.jpg` are prototype-grade per the handoff.
- Not a literally shippable product — the correct, seam-clean foundation for one.
