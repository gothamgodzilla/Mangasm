# Mangasm — Production Roadmap (verified)

**Date:** 2026-06-21
**Author:** Claude Code (Opus 4.8)
**Basis:** 5-agent current-state verification sweep against `docs/production-readiness.md`.
The prior production-readiness audit is **stale in places** — this roadmap supersedes it for
sequencing decisions. Every claim below is grounded in a file:line check, not the audit's prose.

> Decision context: milestone = "plan all 5 phases, build in order." Backend (DB) work is parked
> until the Supabase MCP is authenticated against the **dev** project `pwmddvigardiyhqtihdw` and the
> session is run from the Mangasm repo. **No DDL is applied against the shared project
> `hcpzbxplnkyythzwkovy`.**

---

## 1. Verified current state (corrects the audit)

### Already done — audit was wrong / obsolete
- `EventType` enum already uses App-Store-safe raw values (`open_door`, `social_mixer`, `circle`, `cosplay`) — `Models.swift:475-478`.
- **StoreKit 2 is fully implemented** (no Stripe in the in-app premium path) — `StoreKitStore.swift:16-157`, products/purchase/restore/entitlements all real; `.storekit` config + scheme wired; "Unlock M+" CTA calls `store.purchase()` (`EventsView.swift:232-248`).
- Delete-Account **UI** exists (`SettingsScreen.swift:298-327`); block/report **UI** wired (`ChatThreadScreen.swift:210,238`, `MatchDetailScreen.swift:70,98`).
- `reports` + `blocks` tables already added in migration `0002` (`0002:7-13, 18-28`).
- Real `MangasmiOS.xcodeproj` + `project.yml` (xcodegen, iOS 17, Swift 6) + SPM all exist; unit suite (30 tests) runs via `swift test`.

### Confirmed live blockers
| Area | Finding | Evidence |
|---|---|---|
| 1.1.4 content | Seed data still ships explicit sex-act content into the binary | `Models.swift:554-599` ("Anon Booth", "Anonymous setup, sanitized booths", "twenty-minute slots… in-and-out", "clothing optional", "Full gear encouraged") |
| Sensitive data | **HIV visibility defaults to `true`** | `Models.swift:147` `hiv: Bool = true`; rendered `ProfileScreen.swift:201` |
| False claim | **"END-TO-END ENCRYPTED" banner is cosmetic — no crypto anywhere** | `ProfileScreen.swift:384-409`; messages plaintext `Mocks.swift:66-78`; zero CryptoKit/libsodium |
| Payments | Server-side validation disabled + free unlock | `StoreKitStore.swift:27` `verifyBaseURL=""`; debug toggle `SettingsScreen.swift:244`; entitlement client-trusted `MangasmRootView.swift:21-23` |
| Backend | **All 7 services mock-only**; `supabase-swift` not a dependency; `SupabaseConfig` unused | `Mocks.swift`, `AppEnvironment.swift:34-42`, `Package.swift:11-15` |
| Backend | Both promised triggers are **comment-only** (no DDL) | `0001:54` (mutual-like→match), `0002:154` (rep_score) |
| RLS | `profiles_read using(true)` leaks HIV + socials; `events_read using(true)` leaks location pre-RSVP; no profiles DELETE policy | `0001:167, 190` |
| Compliance | Sign in with Apple is a stub (no `AuthenticationServices`); no EULA acceptance gate; no enforced 18+ affirmation | `SignInView.swift:6,59-61,113-136` |
| Compliance | No `PrivacyInfo.xcprivacy`; no `ITSAppUsesNonExemptEncryption` | repo-wide: 0 hits |
| Safety | `isBlocked` never used to filter Discover/Match/Chat (not bidirectional); photo gate client-only; `consent_ack` visual-only | `Protocols.swift:57` (no call sites), `Mocks.swift:128-130`, `HostEventForm.swift:258` |
| Quality | No XCUITest/snapshot/RLS/StoreKit tests; no crash/analytics SDK; 1 `accessibilityLabel` total; no Dynamic Type / Reduce-Motion; no localization catalog | `Tests/`, `Theme.swift:34-45` |
| Assets | `lambo_hero.jpg` + `runway.mp4` unlicensed-risk, no LICENSE note. (Audit's font risk is **obsolete** — no `.ttf` shipped; falls back to system fonts) | `Sources/MangasmApp/Resources/` |

---

## 2. Re-sequenced phases

Sequencing insight from the sweep: several "rejection blockers" (account deletion, EULA logging,
age-gate logging, block/report persistence) **cannot truly complete without the backend**, so they
move into Phase 2. A cluster of fixes is **pure code with zero external deps** and is pulled forward
into **Phase 0**.

### Phase 0 — Quick wins (pure code, no DB, no Apple portal) ← do first
1. Rewrite all four `EventItem.samples` descriptions + "Anon Booth" title → remove sex-act references (`Models.swift:554-599`). **Open decision A.**
2. Flip HIV visibility default to `false` (`Models.swift:147`).
3. Remove the `(debug) M+ Premium` toggle from Settings (`SettingsScreen.swift:244`).
4. Make the E2E banner honest: relabel to "Encrypted in transit" until real E2E ships (`ProfileScreen.swift:395`). **Open decision B** (build real E2E later vs. drop the claim).
5. Add `ITSAppUsesNonExemptEncryption` to `project.yml` (`INFOPLIST_KEY_…`).
6. Create `PrivacyInfo.xcprivacy` (required-reason APIs + privacy types).
7. Accessibility starters: labels on `MGSwitch`/`RepRing`/`CompatibilityRing`/close buttons; Dynamic Type via `UIFontMetrics`; Reduce-Motion gate on splash/weather FX.

### Phase 1 — Auth + account lifecycle (needs dev DB live)
- Add `supabase-swift` to `Package.swift`; wire `SupabaseConfig` → a real client; add `AppEnvironment.live(client:)` behind a build flag.
- Sign in with Apple (`ASAuthorization` → Supabase `signInWithIdToken`) + Google + phone-OTP; store SIWA email on first sign-in.
- 18+ age affirmation at onboarding, **server-logged**.
- EULA / community-standards acceptance gate at onboarding, **logged** (`consent_log`).
- Real `AuthService.deleteAccount()` (revoke sessions + delete `auth.users` → cascade) + `deletion_requests` table + profiles DELETE RLS policy.

### Phase 2 — Backend foundation (needs dev DB live)
- Migration `0003`: `consent_log`, `deletion_requests`; reconcile `photo_gate` location (`reputation_scores` vs profiles); write the **two missing triggers** (mutual-like→match, rep_score sync) as real `create function`/`create trigger`.
- Fix RLS leaks: restrict sensitive profile fields (view or column RLS enforcing `visibility`); restrict event `place`/`area` to confirmed RSVPs; add profiles DELETE policy.
- Implement live conformances for all 7 services (`Sources/MangasmApp/Services/Live/`).
- Apply `0001`+`0002`+`0003` to dev project; verify tables + run RLS integration tests.

### Phase 3 — Payments hardening (StoreKit already built)
- Deploy `verify-purchase` Edge Function with Apple creds; **real JWS signature verification** (App Store Server library); bind to `auth.uid()`; set `verifyBaseURL`.
- App Store Server Notifications v2 webhook → `profiles.premium` (renew/cancel/refund).
- Make entitlement **server-authoritative** (gate features on server `premium`, not client bool).
- App Store Connect: create the `$9.99/mo` subscription product. **External (you).**

### Phase 4 — Safety / moderation
- Replace `MockSafetyService` with backend writes; enforce **bidirectional** block filtering in all candidate/match/chat queries.
- Photos → private Supabase Storage bucket; signed URLs via Edge Function that checks reputation server-side (client gate becomes UX-only).
- NSFW screening before photos appear; moderation queue (internal tool); 24h SLA. **External accounts (you).**
- Wire event `consent_ack` to a real control + backend write; reveal event location only after RSVP confirmation.

### Phase 5 — Quality / launch
- XCUITest critical paths (sign in, profile edit, like, match, message, RSVP, delete account); snapshot tests; StoreKit sandbox tests; RLS integration tests.
- Crash reporting + first-party analytics (no PII/HIV/fetish in events).
- Finish accessibility + localization catalog + locale-aware dates.
- Confirm/replace `lambo_hero.jpg` + `runway.mp4` licenses. **External (you).**

---

## 3. Decisions (resolved 2026-06-21)
- **A. Distribution → DUAL.** iOS ships a **clean shell** (tasteful seed data + store listing → passes Guideline 1.1.4; StoreKit/IAP for in-app premium). A separate **web surface (mangasm.com / PWA)** carries the fully explicit, kink-friendly, elite/luxury product with **no Apple review** and **Stripe** for the web tier. The adult/kink reality on iOS lives in **user-generated content** (profiles, events, E2E DMs) behind 18+ verification — the Grindr/Scruff model. The web surface is its **own decomposition** (Workstream W below), not part of the iOS phases.
- **B. E2E → BUILD REAL E2E NOW.** Implement true end-to-end encryption for DMs: per-device X25519 keypair (private key in Secure Enclave/Keychain, never uploaded), `device_keys` table for public keys, message bodies encrypted client-side (CryptoKit / libsodium sealed-box), key-verification (safety-number) UI later. Set `ITSAppUsesNonExemptEncryption = YES` and **file an encryption ERN** (external, you). This couples with backend (`device_keys`) + chat, so it lands in **Phase 2/4 chat work**, not Phase 0. Until it ships, the binary must not display a false "end-to-end" claim in any build that goes to TestFlight/review.
- **C. Moderation provider** — OPEN. Rekognition / Google Vision / Persona / Hive for NSFW + identity? (Phase 4.)
- **D. HIV / health data → REMOVED (2026-06-22).** HIV status and the last-tested date were removed from the entire app (Swift, schema, migrations, tests) to eliminate GDPR Art. 9 special-category exposure. Do not reintroduce health-status fields.

## 3a. Workstream W — Web surface (mangasm.com / PWA) [separate decomposition]
Fully explicit adult product, no Apple constraints, Stripe for web subscriptions. Likely reuses the
existing `brain-server` / standalone HTML assets in the home dir. Gets its own spec → plan when the
iOS phases are underway. Shares the same Supabase backend (dev project `pwmddvigardiyhqtihdw`).

## 4. External blockers owned by you
Rotate the leaked `sb_secret_` key · authenticate the dev-project MCP (`claude /mcp`) · register bundle ID + App Store Connect app + subscription product (`dicklicious@icloud.com`) · privacy + moderation policy public URLs · asset licenses · moderation/NSFW accounts.
