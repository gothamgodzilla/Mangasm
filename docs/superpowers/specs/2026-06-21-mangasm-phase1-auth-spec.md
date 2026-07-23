# Mangasm — Phase 1 Spec: Auth + Account Lifecycle

**Date:** 2026-06-21
**Depends on:** dev Supabase project `pwmddvigardiyhqtihdw` reachable via authenticated MCP (run from `~/Mangasm`); leaked `sb_secret_` key rotated.
**Roadmap:** `2026-06-21-mangasm-production-roadmap.md` (Phase 1).
**Criticality:** AUTH + ACCOUNT DELETION are critical paths → **triple-pass verification** (security-engineer + senior-dev lenses) on every function here.

## Goal

Replace the auth stub with real Supabase Auth and satisfy the App Store account blockers:
Sign in with Apple (+ Google + phone-OTP), enforced 18+ age gate, EULA acceptance logging, and a
real in-app account deletion that revokes sessions and cascades data. Views keep talking only to the
protocols in `Services/Protocols.swift`; we add live conformances and inject `AppEnvironment.live`.

## Current state (verified)

- `SignInView.swift:59-61` — Apple/Google/Phone buttons all call `onEnter` (stub); class doc: "auth is stubbed". No `import AuthenticationServices` anywhere.
- `AuthService` (`Protocols.swift`) declares `enter()` + `deleteAccount()`. Only `MockAuthService` (`Mocks.swift:9-12`) exists — `deleteAccount()` just prints.
- Delete-Account UI is real (`SettingsScreen.swift:298-327`) and calls `env.auth.deleteAccount()`.
- `SupabaseConfig` (`SupabaseConfig.swift`) loads URL + publishable key from Info.plist; **wired to nothing**. `supabase-swift` is NOT in `Package.swift`.
- App injects `AppEnvironment.mock` (`MangasmRootView.swift:5`).
- Self-declared `age` field on Profile (`Models.swift:27`); no enforcement, no server log.
- Legal line in `SignInView.swift:113-136` is non-interactive text; no acceptance gate/log.

## Architecture

1. **SDK:** add `supabase-community/supabase-swift` to `Package.swift` (pin a version).
2. **Live services dir:** `Sources/MangasmApp/Services/Live/` — `SupabaseAuthService.swift` (this phase), others in Phase 2.
3. **Client:** build a `SupabaseClient` from `SupabaseConfig.fromInfoPlist()`.
   **[AMENDED 2026-07-23 — supersedes the original fallback rule; see review-polish blocker B3]**
   The `.mock` fallback when config is absent is permitted in **Debug / previews / tests only**.
   A Release/archive build with missing Supabase config must **fail at build time**
   (assertion or CI check) — never silently ship the mock environment. The original
   unconditional fallback is what produced blocker B3 in `docs/pdca/review-polish/plan.md`.
4. **Injection:** add `AppEnvironment.live(client:)`; in `MangasmRootView`, choose `.live` when a client is available, else `.mock`. Keep `.mock` for `#Preview` and tests.
5. **Session:** Supabase JWT persisted in Keychain (SDK default is fine; confirm it uses Keychain, not UserDefaults, for tokens). Silent refresh on launch.

## Features

### 1. Sign in with Apple (primary)

- Add `AuthenticationServices`; use `SignInWithAppleButton` or `ASAuthorizationController`.
- Exchange the Apple identity token via Supabase `auth.signInWithIdToken(provider: .apple, idToken:, nonce:)` with a **cryptographic nonce** (SHA256 hash sent to Apple, raw nonce to Supabase).
- On **first** sign-in only, Apple returns email/full name → upsert into `profiles` then (it's never returned again).
- Apple capability/entitlement (`com.apple.developer.applesignin`) must be added to the target + App ID (external: Apple portal).

### 2. Google + phone-OTP (secondary)

- Google via Supabase OAuth (`auth.signInWithOAuth(provider: .google)`) — requires a Google OAuth client configured in the Supabase dashboard (external).
- Phone-OTP via `auth.signInWithOTP(phone:)` + `auth.verifyOTP(...)`.
- **Guideline 4.8:** Sign in with Apple must be at least as prominent as Google — keep it first/primary.

### 3. Age gate (18+)

- After first successful auth, before app access: a blocking affirmation step (DOB picker or explicit "I am 18+").
- Write a server-side record: `consent_log(user_id, kind='age_18plus', value, created_at)` — timestamp + user id as a legal record. Block entry until written.
- Store derived `is_adult boolean` on the profile; do NOT store plaintext DOB beyond what's needed.

### 4. EULA / community-standards acceptance

- Make the sign-in legal line an **explicit acceptance** (checkbox or "By continuing…" gate that records consent).
- Write `consent_log(user_id, kind='eula', version, created_at)`. Surface the zero-tolerance clause (Guideline 1.2).
- Publish EULA + community guidelines at public URLs (external) and reference the version stored.

### 4a. Email/password sign-in — App Review demo account **[ADDED 2026-07-23]**

Previously this requirement lived only in `APP_REVIEW_NOTES.md` and was never built
(review-polish blocker B2). It is a hard App Review requirement: reviewers cannot use
Sign in with Apple, so a working **email/password** login must be reachable in live mode.

- Supabase Email provider (already enabled) via `auth.signIn(email:password:)`.
- UI: email + password fields reachable from `SignInView` when `usesLiveAuth` is true.
- **Open decision (review-polish plan, open question 3):** sign-in-only (reviewer account
  provisioned server-side) vs. full sign-up flow. Sign-in-only is the smaller change and
  satisfies review; decide before implementing.
- Acceptance: clean install → log in with the demo credentials → reach the main tabs.
- Guideline 4.8 still applies: Sign in with Apple stays the primary/most prominent option.

### 5. Real account deletion (Guideline 5.1.1(v))

- `SupabaseAuthService.deleteAccount()` → call a Supabase **Edge Function `delete-account`** (service-role) that:
  1. verifies the caller's JWT (`auth.uid()`),
  2. deletes the `auth.users` row → cascades all FK rows (FKs already `on delete cascade`),
  3. revokes refresh tokens / signs the user out.
- Add **migration 0003** bits for this phase: `consent_log` table, `deletion_requests` table (only if a disclosed delay window is used; default = immediate delete), and a **profiles DELETE RLS policy** (`using (id = auth.uid())`) so deletion has a row-level path.
- HIV/sensitive fields must be deleted immediately (no retention).

## Schema (migration 0003 — auth subset)

```sql
create table if not exists public.consent_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('eula','age_18plus','hiv_disclosure','orientation_disclosure')),
  version text,
  value text,
  created_at timestamptz not null default now()
);
alter table public.consent_log enable row level security;
create policy consent_log_own on public.consent_log
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- profiles DELETE path for in-app account deletion
create policy profiles_delete_own on public.profiles
  for delete using (id = auth.uid());
```

(deletion_requests deferred unless a delay window is chosen.)

## Edge function: delete-account

- Service-role client; verify caller JWT; `auth.admin.deleteUser(uid)`; return 204.
- Never trust a client-supplied user id — derive from the verified JWT only.

## Testing

- Unit: `SupabaseAuthService` against a mock transport where feasible; nonce generation/hashing correctness.
- Integration (needs dev DB): sign-in round-trip, consent_log writes, RLS (a user cannot read/delete another's consent rows), delete-account cascade verified by row counts → 0.
- Manual: SIWA on a real device (simulator can't fully exercise SIWA), restore session across launches, delete-account then confirm re-signup is clean.
- Triple-pass review of: nonce handling, JWT verification in the edge function, deletion cascade completeness.

## External dependencies (you)

- Apple: add Sign in with Apple capability to App ID + target; ensure `dicklicious@icloud.com`.
- Supabase dashboard: enable Apple + Google providers; add Google OAuth client; SMS provider for phone-OTP.
- Public URLs for EULA + community guidelines.
- Rotate the leaked secret key; authenticate the dev MCP.

## Out of scope (later phases)

Profile/Match/Chat/Event/Reputation live services (Phase 2), real E2E (Phase 2/4), payments hardening (Phase 3), moderation (Phase 4).
