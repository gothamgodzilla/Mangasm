# Handoff: Mangasm — Launch Experience (Splash → Sign-In)

## Overview
This package documents the **app launch sequence** that runs before the Profile/main app: a cinematic runway video splash, animated wordmark + CTA, and a landmark-slideshow sign-in screen. It complements the existing **`design_handoff_mangasm_profile`** package (which covers the main app). Together they describe the full first-launch flow:

```
App opens
  → Runway video plays (cyberpunk leather fashion, looped, 6s clip)
  → "Mangasm" wordmark pulses in with orange glow
  → "ENTER THE COMMUNITY" CTA shimmers in
  → Tap anywhere / SKIP / auto-advance (~8.6s)
  → Landmark slideshow sign-in (Dubai · London · Mykonos · Tokyo)
  → Provider auth (Apple / Google / phone)
  → Main app (Profile — green-Lambo beach)
```

## About the Design Files
The files in `prototype/` are **design references built in HTML/React** — a prototype of the intended look, motion, and flow. **They are not production code to ship directly.** The target codebase is the native iOS app (`Mangasm.xcodeproj`, SwiftUI). Recreate this flow in SwiftUI using the app's existing environment and the `Mangasm_LuxuryUI.swift` design system (gold/teal/purple tokens, `GlassCard`, `LamborghiniBackground`, etc.). In SwiftUI this maps to a `SplashView` → `Onboarding/SignInView` → `MainTabView` router, as outlined in the user's earlier Claude Code notes.

## Fidelity
**High-fidelity (hifi).** Colors, type, timing, and motion below are final.

---

## Design Tokens (launch-specific; shares the app's gold system)

### Color
| Token | Hex | Use |
|---|---|---|
| `launchOrange` | `#F08A38` | **Splash accent** — wordmark glow, kicker, CTA gradient top |
| `launchOrangeDeep` | `#C95E1E` | CTA gradient bottom, border |
| `mgGold` | `#E8C77E` | Sign-in: wordmark, "Enter" button, provider hairlines, active dot |
| `mgGoldDeep` / `mgGoldBright` | `#C9A24B` / `#F8ECC8` | Gold gradient stops |
| Splash grade | `linear-gradient(180deg, rgba(6,4,9,.5) 0%, rgba(6,4,9,.05) 30%, rgba(6,4,9,.35) 62%, rgba(4,2,7,.92) 100%)` | Cinematic darkening over video |
| Sign-in veil | `linear-gradient(180deg, rgba(6,4,9,.55) 0%, …,.12 26%, …,.30 56%, rgba(4,3,7,.94) 100%)` | Legibility over slides |
| Glass (sheet/pills) | see `glass()` in `mangasm-fx.jsx` | hyperreal liquid glass |

### Typography
| Role | Font | Size | Weight / Tracking |
|---|---|---|---|
| Splash wordmark "Mangasm" | Cormorant Garamond | 60 | 700 / +0.01em — orange glow |
| Splash kicker "EST. MMXXVI" | Space Mono | 9 | +0.5em, `launchOrange` |
| Splash tagline | Space Mono | 9.5 | +0.42em, 78% cream |
| CTA "ENTER THE COMMUNITY" | Cormorant Garamond | 16 | 700 / +0.08em, white |
| Sign-in city name | Cormorant Garamond | 40 | 600, white |
| Sign-in city tag (italic) | Cormorant Garamond italic | 15 | 500, cream 82% |
| City coords / labels | Space Mono | 8.5–9 | +0.28–0.34em |
| Sign-in wordmark | Cormorant Garamond | 38 | 700, gold gradient |
| Provider buttons | Mulish | 13.5 | 700 |
| "Enter the community" btn | Cormorant Garamond | 16 | 700 / +0.04em, ink `#2a1d05` on gold |
| Legal microcopy | Space Mono | 7.5 | +0.04em, cream 50% |

### Motion (keyframes — all in `mangasm-launch.jsx`)
| Name | What | Timing |
|---|---|---|
| `mglogoIn` | wordmark: opacity 0→1, translateY 14→0, scale .92→1, blur 6→0 | 1.1s `cubic-bezier(.2,.8,.2,1)`, delay 0.7s |
| `mgglow` | wordmark orange text-shadow pulse | 3.4s ease-in-out infinite, starts 1.8s |
| `mgrise` | generic opacity+translateY(20→0) entrance | 0.9–1s ease |
| `mgctaPulse` | CTA box-shadow breathe | 2.4s infinite |
| `mgshimmer` | CTA diagonal light sweep | 3.2s, starts 3.6s |
| `mgkb` | sign-in slide Ken-Burns (scale 1.02→1.16, slight pan) | 9s ease-out per slide |
| `mgfadeIn` | stage cross-fade | 0.6s |

**Splash timeline:** kicker 0.4s → wordmark 0.7s (then glow loop 1.8s) → tagline 1.5s → CTA 3.1s (shimmer 3.6s). Auto-advance at **8.6s**; SKIP and a full-screen tap-catcher also advance.
**Sign-in:** city auto-cycles every **4.2s**; slide cross-fade **1.4s**; each new city tag re-runs `mgrise`.

---

## Stage 1 — Runway Splash (`Splash`)
- **Video:** `assets/runway.mp4` (portrait 464×688, H.264, ~6s). Full-bleed `object-fit: cover; scale(1.04)`, `autoPlay muted loop playsInline`. In SwiftUI: `AVPlayerLayer` in a `.resizeAspectFill` container, looped, muted; bundle the mp4 in Copy Bundle Resources.
- **Overlays (bottom→top z):** cinematic grade gradient · radial orange screen-blend haze (top-center) · inset vignette `inset 0 0 150px 40px rgba(0,0,0,.7)`.
- **Lockup (bottom ≈132):** kicker "EST. MMXXVI" · wordmark "Mangasm" (orange glow loop) · tagline "DARK LUXURY · BROTHERHOOD · NIGHTLIFE".
- **CTA (bottom 46):** full-width gold→deep-orange gradient button, `mgctaPulse` glow + `mgshimmer` sweep, label "ENTER THE COMMUNITY"; sub "TAP ANYWHERE TO CONTINUE".
- **SKIP** glass pill top-right (z above catcher). A transparent full-bleed `<button aria-label="continue">` (z:1, below CTA/SKIP) makes the whole screen tappable.
- All three paths call `go()` → fade out (0.48s) → `onContinue()` → Stage 2.

## Stage 2 — Landmark Sign-In (`SignIn` + `LandmarkSlides`)
- **Background:** 4 city slides cross-fading every 4.2s, each a **gold line-art skyline silhouette** over a 3-stop twilight sky gradient, with a sun-haze radial, a reflective ground band, and a Ken-Burns scale/pan. **These skylines are placeholder SVG art** — in production swap in real licensed city photos (Dubai, London, Mykonos, Tokyo) behind the same veil + Ken-Burns.
  | City | Coords | Tag | Sky stops |
  |---|---|---|---|
  | Dubai | 25.20° N · 55.27° E | "where the signal shouldn't reach" | `#241a36 → #6e3550 → #e0894a` |
  | London | 51.50° N · 0.12° W | "after-hours, members only" | `#161f3c → #3c3a64 → #bf6a7e` |
  | Mykonos | 37.44° N · 25.32° E | "white walls, gold nights" | `#102634 → #2f6f7c → #e7bd6e` |
  | Tokyo | 35.67° N · 139.65° E | "neon, velvet & rain" | `#191334 → #5a2a4c → #d4585a` |
- **Upper caption (y≈92):** coords (mono) · city name (Cormorant 40) · italic tag · progress **dots** (active dot = gold pill 18px w/ glow).
- **Sign-in sheet (bottom, glass, radius 30):** grab-handle · "Mangasm" gold wordmark + "BY INVITATION · MEMBERS ONLY" · three provider buttons (**Continue with Apple** dark; **Google**; **phone**) · "OR" divider · **"Enter the community →"** gold button · legal line with underlined **COMMUNITY GUIDELINES** / **PRIVACY**.
- Every auth control calls `onEnter()` → main app. (Wire to real Sign in with Apple / Google Sign-In / phone-OTP; the prototype stubs all to enter.)

## Interactions & State
- `LaunchFlow` holds `stage: 'splash' | 'signin'`. `MangasmApp` holds `phase: 'launch' | 'app'`; `onEnter` sets `phase='app'`.
- **Replay:** Tweaks panel → "Replay intro" sets screen to profile and `phase='launch'`.
- SwiftUI mapping: `enum LaunchPhase { case splash, signIn, app }` on an `AppRouter`; splash auto-advance via a `Task`/timer that respects SKIP/tap; sign-in city cycle via `TimelineView` or a `Timer`.

## Updated background & weather (since the Profile handoff)
These edits live in `prototype/mangasm-fx.jsx` and supersede the corresponding sections of the Profile handoff:
- **Background is the green Lamborghini beach**, not a stock photo. `assets/lambo_hero.jpg` is a **portrait plate** built from the mockup: the car is anchored at the bottom, the beach/water/skyline rise above it, and a twilight sky gradient is synthesized above the photo seam so it fills a tall screen. `background-position: 50% 100%`. In SwiftUI this is the `LamborghiniBackground` slideshow — use a real clean green-Lambo render at full res (the plate here is salvaged from the UI mockup).
- **Glass is more transparent / hyperreal** (`glass()`): clearer body, `blur(22px) saturate(150%) brightness(1.04)`, brighter specular rim `inset 0 1px 0 rgba(255,255,255,.72)`, soft inner bottom shade. SwiftUI: `.ultraThinMaterial` + a thin bright top stroke + subtle inner bottom gradient.
- **Hyperreal rain + rain-on-glass** (new `Rain`, `RainGlass`, `Frost`, `WeatherFX`): rain is now **two depth layers** (far blurred / near sharp). `RainGlass` overlays **condensation beads** (radial highlight + dual inset shadow) that bob, plus **rivulets** that slide down (`mgriv`) leaving a wet trail with a droplet head. Snow/sleet add a `Frost` vignette. SwiftUI: render beads/rivulets as a `Canvas`/`TimelineView` particle layer over the photo; throttle and pause off-screen.

## Assets
- `prototype/assets/runway.mp4` — splash video (portrait, H.264, ~6s, looped & muted).
- `prototype/assets/lambo_hero.jpg` — portrait green-Lambo beach background plate. **Replace with a clean high-res render for production.**
- Sign-in skylines are inline SVG (`SKY` object in `mangasm-launch.jsx`) — **placeholder**; swap for licensed city photography.
- Fonts: Cormorant Garamond, Mulish, Space Mono (OFL) — bundle in-app.

## Files
- `prototype/Mangasm.html` — **entry** for the full experience; renders `<MangasmApp launch />`.
- `prototype/mangasm-launch.jsx` — **the launch sequence** (`LaunchFlow`, `Splash`, `SignIn`, `LandmarkSlides`, `ProviderBtn`, `SKY` skylines, `CITIES`, keyframes). Primary reference for this package.
- `prototype/mangasm-fx.jsx` — shared tokens, `glass()`, the updated weather system (`WeatherFX`/`Rain`/`RainGlass`/`Frost`), and the `Background` (green-Lambo plate).
- `prototype/mangasm-shell.jsx` — `MangasmApp` (now has `phase` launch gate, `initialScreen`, `noChrome`) + `TabBar`. Structural reference.
- `prototype/mangasm-screens.jsx`, `mangasm-profile.jsx`, `mangasm-match.jsx`, `mangasm-chat.jsx` — main-app screens (documented in the Profile handoff).
- `prototype/ios-frame.jsx`, `tweaks-panel.jsx`, `image-slot.js` — scaffolding (reference only).

To preview: open `prototype/Mangasm.html` in a browser. See **`design_handoff_mangasm_profile/`** for full documentation of the main app screens.
