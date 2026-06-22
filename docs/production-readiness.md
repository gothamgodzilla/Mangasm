# Mangasm — Production Readiness Audit

**Date:** 2026-06-21  
**Auditor:** Claude Code  
**App State:** SwiftUI front-end complete (mock backend only). Supabase schema authored, not applied. No Xcode project — SPM only. No IAP, no push, no real auth.

---

## Summary: Top 3 Blockers

| # | Blocker | Why it matters |
|---|---------|----------------|
| 1 | **Stripe is not valid for digital subscriptions on iOS** | Apple requires StoreKit/IAP for all in-app digital premium tiers. Stripe web checkout for M+ ($9.99/mo) will cause App Store rejection under Guideline 3.1.1. This is a payment architecture change, not a config change. |
| 2 | **Zero real backend** — auth, profiles, chat, events all mock | No user can create an account, be verified as 18+, or have their data persist. The app cannot pass App Store review without functional auth + account deletion flow. |
| 3 | **The app's event content (glory holes, cum-and-go, anon booths in seed data)** is hookup-app territory under Guideline 1.1.4 | Apple rejects apps that facilitate anonymous sexual encounters. The event type taxonomy (`glory`, `cumgo`, `circle`, `cosplay`) is directly in the binary and will trigger review. This requires a content strategy decision before submission — not just a UX tweak. |

---

## 1. App Store Review Risks & Requirements

### 1.1 Guideline 1.1.4 — Overtly Sexual / Hookup Content

**Risk level: HIGH — likely rejection without changes.**

The current seed data (`Models.swift`, `EventType`) includes event types with raw values `"glory"`, `"cumgo"`, `"circle"`, `"cosplay"` and seed events titled "Anon Booth", "Lunch Express", "Sunset Circle" with descriptions explicitly referencing "anonymous setup", "sanitized booths", "twenty-minute slots." This content is in the compiled binary.

Apple's position on hookup apps (Grindr, Scruff, Recon all ship with this restriction): apps may facilitate dating and social connection but cannot be a vehicle for arranging anonymous sexual encounters. The event model is the risk.

**Required before submission:**

- [ ] Remove `glory`, `cumgo`, `circle` as publicly named event types from the binary. Replace with category names that do not refer to sex acts. The consent/safety model can remain — only the taxonomy needs to change.
- [ ] Strip explicit descriptions from seed/demo data. Any data shipped with the binary that describes anonymous sex acts is a problem even in a mock layer.
- [ ] Review all visible strings (event labels, event descriptions in mock data) against Guideline 1.1.4 before first submission.
- [ ] The app is a "gay dating app" — this is fine and reviewable. Position it as social + dating with adult event categories, not hookup facilitation.

**Note:** Apple has approved many gay dating apps. The risk is the specific event naming, not the app's purpose. Rename at the taxonomy level; the product intent can remain.

### 1.2 Guideline 1.2 — User-Generated Content Safety

Apple requires all UGC apps to meet four requirements:

| Requirement | Current state | Gap |
|---|---|---|
| Content filtering | No backend, no filtering | Not built |
| Block and report in-app | No real implementation | UI scaffold only |
| EULA / Community Standards with zero tolerance for objectionable content | Not present | Must be written and surfaced at onboarding |
| 24-hour action on reported content | No moderation pipeline | Not built |
| Published moderation policy (URL in metadata) | Not present | Must exist at a public URL before review |

**Required:**

- [ ] Real moderation pipeline (human or ML+human escalation) must exist and be operable before App Store submission.
- [ ] Block/report must be wired to real backend — not mock.
- [ ] EULA accepting zero-tolerance policy must appear at account creation and be logged in the database.
- [ ] A published moderation policy URL must be supplied in App Store Connect metadata.

### 1.3 Age Assurance (18+ gating)

The app stores an `age` field in the profile. This is self-declared and not verified. Dating apps with adult content — especially apps explicitly marketed to gay men with event categories for sexual encounters — face heightened review scrutiny on age verification.

**Current state:** `age >= 18` check in the Postgres schema (not yet applied). No enforcement at signup.

**Required:**

- [ ] Age gate at onboarding: user must affirm they are 18+ before accessing the app.
- [ ] The affirmation must be logged server-side (timestamp + user ID) as a legal record.
- [ ] Apple does not require biometric age verification for dating apps, but does require a clear, enforceable gate. A checkbox + server log is the minimum; ID verification is a differentiator and reduces legal exposure.
- [ ] Consider adding DOB collection at onboarding (required, not optional) and storing it for compliance.

### 1.4 Mandatory Account Deletion (Guideline 5.1.1(v))

Since June 2023, Apple requires all apps that support account creation to provide in-app account deletion. This is mandatory — not optional.

**Current state:** Not implemented. Settings screen has no "Delete Account" option. The Supabase schema has `on delete cascade` on all foreign keys, which is correctly designed for this — but no UI or API endpoint exists.

**Required:**

- [ ] "Delete Account" button in Settings, accessible without contacting support.
- [ ] Deletion must: revoke all sessions, delete all user data (or begin a documented retention window), and delete the auth.users row (cascades via schema design).
- [ ] A 30-day deletion delay is acceptable if disclosed. Immediate deletion is simpler.
- [ ] This is a TestFlight blocker — Apple checks for this during review.

### 1.5 In-App Purchase / StoreKit (CRITICAL — Guideline 3.1.1)

**The current plan to use Stripe for M+ subscriptions is not permitted on iOS.**

Apple's Guideline 3.1.1 is explicit: digital goods and services sold within an iOS app must use Apple's IAP system. Stripe checkout (even via a web view or Edge Function) for a subscription that unlocks in-app features is prohibited. Apple takes 15–30% of subscription revenue through StoreKit.

**Current plan per `docs/backend-integration.md`:** "Stripe: Edge Function for checkout + webhook → profiles.premium"

**This will result in App Store rejection.**

**Required:**

- [ ] Replace the Stripe M+ subscription with `StoreKit 2` (Swift API, iOS 15+, covers the app's iOS 17 minimum).
- [ ] Create a subscription product in App Store Connect (`$9.99/mo` or equivalent).
- [ ] On purchase: `Transaction.currentEntitlements` → confirm entitlement → write `premium = true` to Supabase via the real backend (server-side receipt/JWT validation, not client trust).
- [ ] Subscription status must be verified server-side (use App Store Server Notifications v2) — do not trust client-reported premium status.
- [ ] Stripe can be used for other revenue streams (web subscriptions, merchandise) but NOT for the iOS in-app M+ gate.
- [ ] The Events "Unlock M+ $9.99/mo" CTA in `EventsView` must launch StoreKit, not a web checkout.

### 1.6 Sign In with Apple (Guideline 4.8)

If the app offers third-party social login (the current UI shows Apple, Google, and phone/OTP buttons), Apple Sign In must be offered and must appear at least as prominently as any other provider.

**Current state:** "Apple" button exists visually. `onEnter()` is the stub for all providers.

**Required:**

- [ ] Sign In with Apple must be wired first and be the primary CTA (it already appears first in the spec — maintain this order).
- [ ] Google Sign In: requires proper OAuth integration. The app currently shows a "Google" button; the real flow requires the Google Sign-In SDK or Supabase OAuth.
- [ ] Phone OTP is acceptable as an alternative.
- [ ] The SIWA `user.email` is provided on first sign-in only — store it in the profiles table at that point.

---

## 2. Privacy

### 2.1 PrivacyInfo.xcprivacy (Required from May 2024)

All new iOS app submissions require a `PrivacyInfo.xcprivacy` manifest declaring every privacy-sensitive API and required-reason API the app uses.

**Current state:** No `PrivacyInfo.xcprivacy` file anywhere in the repo.

**Required APIs to declare (based on features in the app):**

| API | Category | Required reason code |
|---|---|---|
| `UserDefaults` (likely used by Supabase SDK + AppState persistence) | Required Reason | `CA92.1` (app functionality) |
| `FileTimestamp` (if used) | Required Reason | — |
| Precise location (Discover/Nearby) | Privacy usage | `NSLocationWhenInUseUsageDescription` |
| Camera (photo upload) | Privacy usage | `NSCameraUsageDescription` |
| Photo library (avatar/photo upload) | Privacy usage | `NSPhotoLibraryUsageDescription` |
| Microphone (if voice features added) | Privacy usage | — |

**Required:**

- [ ] Create `PrivacyInfo.xcprivacy` in the app bundle (must be a proper Xcode target resource — note the SPM-only structure complicates this; an Xcode project may be needed for App Store submission anyway).
- [ ] Audit every SDK dependency (Supabase Swift SDK, future StoreKit, analytics) for their own required-reason API usage and aggregate into the manifest.

### 2.2 App Tracking Transparency (ATT)

If the app uses any cross-site tracking, advertising, or attribution SDKs, ATT must be requested before data collection begins.

**Current state:** No analytics SDK. No ATT prompt.

**Required:**

- [ ] If Crashlytics, Amplitude, Mixpanel, or similar is added: declare `NSUserTrackingUsageDescription` and call `ATTrackingManager.requestTrackingAuthorization` before any tracking begins.
- [ ] If the app uses only first-party analytics (Supabase logs, custom events): ATT is not required but `NSPrivacyTrackingDomains` must be accurate.

### 2.3 Data Collection Disclosures (App Store Connect — Privacy Nutrition Label)

**Fields that will require disclosure:**

| Data type | Sensitivity | Collection | Linked to identity | Used for tracking |
|---|---|---|---|---|
| Name | Standard | Yes | Yes | No |
| Email / phone | Contact | Yes | Yes | No |
| Precise location | Sensitive | Yes | Yes | No |
| Sexual orientation (position, into, hiv) | **Sensitive** | Yes | Yes | No |
| Photos | Sensitive | Yes | Yes | No |
| Health info (HIV status, PrEP) | **Sensitive** | Yes | Yes | No |
| Purchase history (M+ subscription) | Financial | Yes | Yes | No |
| Messages (chat) | Sensitive | Yes | Yes | No |

HIV status and sexual orientation are legally sensitive data under GDPR (Article 9 special category), CCPA, and several US state privacy laws. Their collection requires explicit opt-in consent, not just disclosure.

**Required:**

- [ ] Privacy nutrition label must accurately declare all data categories above.
- [ ] At onboarding, HIV status and sexual orientation fields must have an explicit opt-in consent step — separate from the EULA.
- [ ] HIV status visibility defaults to `true` in the current mock (`Visibility.sample`). This is dangerous. Default should be `false` (hidden) until the user actively opts to show it.
- [ ] Data minimization: collect HIV status only if the user chooses to disclose it. Do not make it a required field.

### 2.4 Encryption Export Compliance

The app markets E2E-encrypted messaging as a core feature. This triggers US Bureau of Industry and Security export compliance.

**Required:**

- [ ] Set `ITSAppUsesNonExemptEncryption = YES` in `Info.plist`.
- [ ] File an Encryption Registration (ERN) with the BIS. For standard HTTPS + E2E chat using AES/TLS, the exemption under EAR 740.17(b)(1) likely applies — but it must be documented and filed.
- [ ] App Store Connect will ask about encryption on every submission. Answer honestly; the exemption is straightforward for a standard messaging app.

### 2.5 GDPR / CCPA

The app targets users in UAE (seed data) and by design is global (London, Tokyo, Mykonos in the launch slides).

**Required:**

- [ ] Privacy policy must exist at a public URL, be linked from the app (visible in Settings, in the sign-in legal line), and be linked in App Store Connect.
- [ ] For EU users: lawful basis for processing special-category data (health + sexual orientation) must be explicit consent, not legitimate interest.
- [ ] Right to erasure ("right to be forgotten") must be honored — the account deletion flow covers this if implemented correctly.
- [ ] CCPA: California users must be able to opt out of data sale (not applicable if no data is sold, but must be disclosed).
- [ ] Cookie banner / consent management is not required for native apps but the privacy policy must cover server-side logging.

---

## 3. Safety & Trust (Core Product)

### 3.1 Real Moderation Pipeline

The app is built around trust signals (reputation, vouches, rep-gated photos) but none of this is enforced in production today.

**Required before public launch:**

- [ ] Content moderation for profile photos: ML-based NSFW screening (e.g. AWS Rekognition, Google Vision SafeSearch, or Azure Content Moderator) before photos appear in any other user's feed.
- [ ] Moderation queue for human review of reported content (24-hour SLA per Apple Guideline 1.2).
- [ ] Automated text moderation for chat messages (at minimum: spam/scam pattern detection).
- [ ] Event descriptions moderated before publication (approval-required events support this flow — wire it to a moderator dashboard).

### 3.2 Block and Report

**Current state:** No real block/report. Protocol seam exists (`ReputationService`) but no method for block/report.

**Required:**

- [ ] Add `func block(userID: UUID)` and `func report(userID: UUID, reason: String)` to the protocol layer and wire to real backend.
- [ ] Blocked users must not appear in Discover, Match, or Chat for either party (bidirectional).
- [ ] Reports must be stored in a `reports` table with the reporting user, reported user, reason, and timestamp.
- [ ] Hosts of an event can see and remove attendees (the host-read RSVPs RLS policy supports this — but the UI and moderation action must be built).

### 3.3 Photo Verification / Reputation Gating

**Current state:** Photo gating is client-side (`canViewPhotos(viewerScore:targetGate:)`). Photos are Unsplash URLs in mock.

**The photo gate only works if enforced server-side.**

**Required:**

- [ ] Photos stored in Supabase Storage (`photos` private bucket).
- [ ] Signed URLs generated by an RPC/Edge Function that checks `auth.uid()` reputation score against the target's `rep_gate` before issuing the URL.
- [ ] Client-side gating is a UX affordance only — it is trivially bypassed. Server-side enforcement is mandatory.
- [ ] Face liveness check for profile photo verification is a recommended differentiator (reduces catfishing and bots) — use a third-party provider (Jumio, Onfido, Persona).

### 3.4 HIV Status Privacy

HIV status is the most legally sensitive field in the app.

**Required:**

- [ ] Default visibility to `false` (not disclosed) until user explicitly enables it. **Current mock default is `true` — this must change.**
- [ ] HIV status must never be shared with third parties for any purpose.
- [ ] HIV status must not appear in any analytics events.
- [ ] When a user deletes their account, HIV status must be deleted immediately — no retention window.
- [ ] If HIV status is stored in Supabase, it must be encrypted at rest using Vault or column-level encryption.
- [ ] Consider whether HIV status needs to be stored server-side at all vs. derived from a client-encrypted field that the server cannot read.

### 3.5 Location Privacy Zones

The spec references "privacy zones" in the Discover screen. The FakeMap is stylized and does not use real GPS.

**When real location is added:**

- [ ] Never reveal precise GPS coordinates to other users. Show distance or neighborhood only.
- [ ] Privacy zones: user-configurable radius (minimum 500m recommended) that fuzzes their displayed location.
- [ ] Do not log precise GPS coordinates in analytics.
- [ ] Location access: `WhenInUse` only — do not request `AlwaysOn` location permission. Reviewers will reject an app requesting always-on location for a dating use case without a clear justification.
- [ ] Consider allowing users to set a manual "home base" location rather than using GPS at all (protects users in regions where homosexuality is criminalized).

### 3.6 Consent Model for Events

**Current state:** The schema has `consent_ack boolean` on events (host affirms consent code). This is good schema design.

**Required:**

- [ ] The `HostEventForm` `consent_ack` must be wired to a real backend write. Currently visual only.
- [ ] RSVP attendees must be shown a consent/safety summary for approval-required events before their RSVP is confirmed.
- [ ] Event location must not be revealed until RSVP is confirmed (the `approval` privacy type supports this — implement the location reveal gate in the backend).
- [ ] "No recording" policy (in the spec's consent note) should be a visible in-app reminder, not just a legal clause.

---

## 4. Engineering Gaps to Production

### 4.1 Replace Mock Layer with Supabase

**Status:** Protocol seam is clean. Zero real implementations exist.

| Protocol | Work required |
|---|---|
| `AuthService` | SIWA + Google OAuth + phone OTP via Supabase Auth. Token management, session refresh. |
| `ProfileService` | CRUD on `profiles` table. Avatar/photo upload to Storage. |
| `MatchService` | Like/match writes. PostGIS nearby query or haversine RPC. Real-time like notifications. |
| `ChatService` | Messages + conversations with Supabase Realtime subscriptions. Unread count. |
| `EventService` | Events + RSVPs + communities. Approval workflow for restricted events. |
| `ReputationService` | Rep score reads, vouch writes, server-side photo URL signing. |

**Steps:**

1. Confirm target Supabase project (dev project first — do not point `DDL` at the shared project without explicit authorization per `backend-integration.md`).
2. Apply `0001_mangasm_init.sql`.
3. Add `supabase-swift` to `Package.swift`.
4. Implement `Sources/MangasmApp/Services/Live/` with real conformances.
5. Inject `AppEnvironment.live(client:)` behind a build flag (`.mock` remains for previews).

**Schema gaps identified in `0001_mangasm_init.sql`:**

- No `reports` table — required for block/report.
- No `blocks` table — required for bidirectional blocking.
- No `photo_gate` column on profiles (the `rep_score` on the viewer is compared to what on the target? A `photo_rep_gate` column is implied by `ReputationService` but absent from the schema).
- No `deletion_requests` table for the 30-day deletion window if used.
- No `consent_log` table for EULA acceptance + HIV disclosure consent.
- Missing trigger that creates a `match` when mutual `like` exists (referenced in `backend-integration.md` but not in the migration).
- Missing `rep_score` update trigger when a vouch is written.

### 4.2 StoreKit 2 (replaces Stripe)

- [ ] Add `StoreKit` framework (built into iOS — no package needed).
- [ ] Create `MangasmPremiumStore.swift`: `Product.products(for:)` → display → `product.purchase()` → `Transaction.currentEntitlements`.
- [ ] Server-side validation: use App Store Server API to verify receipts — do not trust client.
- [ ] Handle subscription lapses: if `Transaction.currentEntitlements` is empty, revert `premium = false`.
- [ ] Restore purchases UI must be present in Settings (required by App Store guidelines).

### 4.3 Push Notifications

- [ ] Register for push via `UNUserNotificationCenter` at appropriate moment (after onboarding, not on cold launch).
- [ ] APNs token → Supabase via `upsert` on a `push_tokens` table.
- [ ] Trigger push from: new message, new match, RSVP confirmed.
- [ ] Use a backend-side push sender (Supabase Edge Function → APNs, or a service like OneSignal).
- [ ] Do not send push for blocked users.
- [ ] Notification content must not reveal sensitive fields (no HIV status, no fetishes) in the notification payload.

### 4.4 Real Photo Storage + Signed URLs

- [ ] Private `photos` Supabase bucket. No public access.
- [ ] Upload photos via `StorageFileAPI` at profile setup.
- [ ] Serve photos via signed URLs with short TTL (e.g. 1 hour) generated server-side after reputation check.
- [ ] Photo compression on upload (target < 1 MB per photo).
- [ ] NSFW screening before photos are visible to other users.

### 4.5 Crash Reporting & Analytics

- [ ] Integrate Sentry or Crashlytics for crash reporting (required to diagnose production issues).
- [ ] First-party event analytics (Supabase database events or a lightweight SDK like PostHog) to understand funnel drop-off.
- [ ] Do not log PII, HIV status, or fetish data in analytics events.
- [ ] If using Firebase Crashlytics: ATT declaration is required.

### 4.6 Offline & Error States

- [ ] Every network call needs a loading, error, and empty state.
- [ ] Chat must queue messages when offline and deliver on reconnect.
- [ ] Profile saves must be optimistic with rollback on failure.
- [ ] Session expiry must redirect to sign-in without data loss.

### 4.7 Accessibility

- [ ] VoiceOver: every interactive element needs an `accessibilityLabel`. The custom `MGSwitch`, `Seal`, `RepRing`, `CompatibilityRing`, and glass pill components currently have none.
- [ ] Dynamic Type: all `MGFont` sizes should scale with the user's preferred text size. Fixed-point font sizes (e.g. `MGFont.mono(8.5)`) will not scale. Use `UIFontMetrics` or relative scaling.
- [ ] Minimum touch target: 44×44 pt. Several components (the 32×32 close button, small chips) are below this threshold.
- [ ] Color contrast: gold on dark backgrounds passes WCAG AA in most cases but should be audited with a contrast checker for the `MGColor.inkFaint` text variants.
- [ ] Reduce Motion: the splash screen animation sequence (8.6s auto-advance, pulse, shimmer, glow) and weather FX should respect `@Environment(\.accessibilityReduceMotion)`.

### 4.8 Localization

- [ ] The app currently has no `Localizable.strings` or `LocalizableStrings.xcstrings`. All strings are hardcoded.
- [ ] For an App Store launch, English-only is acceptable but all user-facing strings should be in a strings catalog to enable future localization.
- [ ] Date/time formatting (event "Tonight · 10:30 PM") should use `DateFormatter` with locale awareness, not hardcoded strings.

### 4.9 Font & Asset Licensing

- [ ] Cormorant Garamond, Mulish, Space Mono are SIL OFL — free to bundle in an app. **Verify this before App Store submission** (OFL permits bundling; confirm no additional terms apply to the specific weight files).
- [ ] `lambo_hero.jpg`: this must either be licensed for commercial use or replaced. A photograph of a Lamborghini is not licensable from Google Images. If sourced from a stock photo service, the license must cover app distribution.
- [ ] `runway.mp4`: same issue — source and license must be confirmed.
- [ ] Unsplash URLs used as avatar/photo URLs in seed data are fine for development but must not appear in production (real user photos will be Supabase Storage URLs).

---

## 5. Testing & QA

### 5.1 Current Test Coverage

| Suite | Tests | What's covered |
|---|---|---|
| `AppStateTests` | ~6 | Phase transitions, tab state |
| `ModelTests` | ~8 | Profile, Candidate, Visibility, Event seeds |
| `ServiceTests` | ~6 | Mock service protocol conformance |
| `SkylineTests` | ~4 | Skyline shape rendering geometry |
| `ThemeTests` | ~3 | Color/font token existence |
| **Total** | **27** | **Models + mocks only. Zero network, zero Supabase, zero StoreKit, zero UI.** |

### 5.2 Production Testing Gaps

| Area | Gap | Priority |
|---|---|---|
| UI Tests (XCUITest) | None exist | High — required for TestFlight smoke |
| Snapshot tests | None | Medium — catches visual regressions |
| Supabase RLS integration tests | Not possible (schema not applied) | Critical — must verify before launch |
| StoreKit Sandbox | Not built | Critical — must test full purchase flow |
| Push notification delivery | Not built | High |
| E2E chat encryption | Claimed in UI; no implementation | Critical — must be built and tested |
| Network failure states | No tests | High |
| Accessibility audit (Xcode) | Not run | Medium |
| Security review of RLS policies | Manual review done in this audit | High — need a second pass by a Postgres/Supabase security reviewer |
| Penetration test | Not done | Required before public launch |

### 5.3 RLS Policy Observations (from `0001_mangasm_init.sql`)

The RLS policies are generally well-designed but have the following gaps:

| Issue | Detail |
|---|---|
| `profiles_read` allows any authenticated user to read all profile fields including HIV status | Consider a separate RLS policy or view that excludes sensitive fields from bulk reads and only exposes them when a user explicitly navigates to a profile they have permission to view. |
| No row-level delete policy on profiles | Users should be able to delete their own profile row (required for account deletion). |
| No insert policy on messages | The `messages_send` policy only covers `INSERT` — the `for insert` syntax is correct, but there is no `UPDATE` or `DELETE` policy, meaning messages are immutable (which may be intentional). |
| `events_read` is world-open to all authenticated users | Location of approval-required events is readable before RSVP is confirmed. This may reveal sensitive location data. Consider restricting full event detail (place/area) to confirmed attendees. |
| No `photo_rep_gate` field | The schema lacks a column to store the minimum rep score required to view photos. `canViewPhotos(viewerScore:targetGate:)` in the protocol needs a gate value to compare against — currently undefined in the schema. |
| Missing mutual-like-to-match trigger | Referenced in documentation but absent from the migration. |

---

## 6. Prioritized Checklists

### Before First TestFlight

These are hard blockers for internal testing. TestFlight does not require App Store review but Apple performs basic checks.

**Legal / Account:**
- [ ] Account deletion flow built and functional (Apple checks this)
- [ ] Sign In with Apple wired (real OAuth, not stub)
- [ ] Age gate (18+ affirmation) at onboarding, server-logged

**Content:**
- [ ] Event type taxonomy reviewed and renamed — remove explicit sex-act references from binary
- [ ] Seed/demo data stripped of explicit event descriptions

**Architecture:**
- [ ] Schema applied to a dev Supabase project
- [ ] At least `AuthService` + `ProfileService` wired to real Supabase
- [ ] `PrivacyInfo.xcprivacy` manifest created
- [ ] Encryption export compliance flag set in Info.plist (`ITSAppUsesNonExemptEncryption`)

**Privacy defaults:**
- [ ] HIV status visibility default changed to `false`
- [ ] Explicit consent step for HIV status disclosure at first profile setup

**Asset licensing:**
- [ ] `lambo_hero.jpg` — confirm commercial license or replace
- [ ] `runway.mp4` — confirm commercial license or replace

---

### Before Public App Store Launch

These are required for App Store approval and safe public operation.

**App Store compliance:**
- [ ] Stripe → StoreKit 2 migration complete for M+ subscription
- [ ] Restore purchases UI in Settings
- [ ] Server-side receipt validation for StoreKit
- [ ] App Store Connect privacy nutrition label completed (all data types declared)
- [ ] Privacy policy at public URL, linked in-app and in App Store Connect
- [ ] Moderation policy at public URL, linked in App Store metadata
- [ ] EULA with zero-tolerance clause shown and accepted at account creation
- [ ] Community Guidelines linked from sign-in (already in the spec — must be real URL)

**Backend completeness:**
- [ ] All 6 service protocols wired to real Supabase (`AuthService`, `ProfileService`, `MatchService`, `ChatService`, `EventService`, `ReputationService`)
- [ ] Missing schema additions applied: `reports`, `blocks`, `photo_rep_gate`, `consent_log`, mutual-like trigger, rep_score trigger
- [ ] Photo storage: private bucket + signed URLs + server-side reputation check
- [ ] Real-time chat (Supabase Realtime subscriptions)
- [ ] Push notifications (APNs + Edge Function sender)

**Moderation:**
- [ ] Photo NSFW screening pipeline before photos appear in feed
- [ ] Block/report functional and writing to database
- [ ] Moderation queue UI (internal tool) for reviewing reports
- [ ] 24-hour response SLA operable

**Safety:**
- [ ] Server-side enforcement of photo reputation gate (signed URL RPC)
- [ ] Event location revealed only after RSVP confirmation for approval events
- [ ] HIV status encrypted at rest in Supabase (Vault or column encryption)
- [ ] Location privacy zones: minimum 500m fuzz on displayed proximity

**Quality:**
- [ ] XCUITest suite covering all critical paths (sign in, profile edit, like, match, send message, RSVP, delete account)
- [ ] Snapshot tests for key screens
- [ ] Supabase RLS integration tests against dev project
- [ ] StoreKit sandbox purchase flow tested end-to-end
- [ ] Security review of RLS policies by independent reviewer
- [ ] Penetration test of E2E chat implementation
- [ ] Accessibility audit (Xcode Accessibility Inspector + VoiceOver on device)
- [ ] Dynamic Type audit at all accessibility text sizes

**Legal / Compliance:**
- [ ] GDPR explicit consent recorded for HIV status and sexual orientation
- [ ] Encryption export ERN filed or exemption documented
- [ ] Font licenses confirmed for all bundled `.ttf` files
- [ ] Photo/video asset licenses confirmed for all bundled production assets
- [ ] Legal review of event consent model (consent_ack as host acknowledgment — confirm it is sufficient in target jurisdictions)

---

## Appendix: IAP vs Stripe — The Full Picture

The existing backend integration plan calls for Stripe to power M+ subscriptions. This is understandable from a developer economics perspective (Stripe charges ~2.9% vs Apple's 15–30%), but it is not viable for an iOS in-app premium feature gate.

**What is allowed:**
- Using Stripe for web subscriptions (a separate mangasm.com subscription) that does not gate iOS features
- Using Stripe for one-time purchases of physical goods
- Pointing iOS users to a web paywall that is not referenced from within the app

**What is not allowed (and will cause rejection):**
- Any in-app button or flow that uses Stripe/web checkout to unlock in-app functionality
- Referencing external purchase options for M+ from within the app (Guideline 3.1.3 does not apply here — that's for "reader" apps, not dating/social apps)

**Recommended architecture:**
- StoreKit 2 subscription in-app for iOS
- App Store Server Notifications v2 webhook → Edge Function → `profiles.premium = true` in Supabase
- Stripe can power a separate web-only "M+ Web" tier if desired, but it must not be the iOS upgrade path

The StoreKit migration is the highest-priority engineering change before App Store submission.
