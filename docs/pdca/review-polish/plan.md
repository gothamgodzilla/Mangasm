# Plan: Reviewer-Path Polish — App Store Submission (v1.1.0)

**Scope decided 2026-07-21:** reviewer-path only · code must match APP_REVIEW_NOTES.md claims · submit ASAP · iOS surface (+ the backend pieces those claims depend on).
**Source of truth:** ultracode audit `wf_33b2ba8c-36e` — 7 claims audited, every gap adversarially verified (29 agents). Full results: workflow journal. Tests currently green: 85/85.

## Hypothesis

The binary builds clean and tests pass, but four of the seven review-note claims are
not true of the code as written. Apple's reviewer will test each claim by hand;
submitting as-is risks rejection under Guidelines 1.2 (UGC controls) and 2.3.1
(inaccurate metadata). Making the code match the notes (chosen remedy) requires the
blockers below; the majors close the gaps a reviewer could stumble into.

## Confirmed BLOCKERS (must fix before submit)

### B1 — No content filter exists (claim #1 is false)
- Message path: `ChatThreadScreen.swift:363-378` → `SupabaseChatService.swift:161-176` inserts raw body; only whitespace trimming (`ChatInboxCache.swift:34-44`).
- Profile path: `SupabaseMatchService.swift:61-94` renders raw bio/headline. No backend trigger/constraint/function inspects content.
- **Requirement:** objectionable-content filtering applied to message send and profile save (shared denylist in the domain layer + server-side enforcement), with regression tests that fail without the filter.
- **Acceptance:** typing test profanity into a bio or message is filtered/rejected in the live build.

### B2 — No email/password login exists in live auth (demo account impossible)
- `SignInView.swift:163-179`: when `usesLiveAuth`, ONLY Sign in with Apple renders; Google/Phone buttons are mock-mode only; the only TextField is the invite code.
- Review notes promise an email/password demo login (required — reviewers can't use SIWA). Demo creds "Opal" exist in secrets.env but no UI can consume them.
- **Requirement:** email/password sign-in reachable in live mode (Supabase email provider already enabled per notes).
- **Acceptance:** clean install → log in with the Opal demo credentials → reach the main tabs.

### B3 — Archive silently falls back to all-mock services
- `AppEnvironment.swift:52` returns the mock environment when `SupabaseConfig.fromInfoPlist()` is nil; adversarial check escalated to blocker after inspecting the actual archive. Mock blocks/reports are in-memory only — every 1.2 control would be fake in front of the reviewer.
- **Requirement:** the shipped archive must run live services; missing config must fail the build (not silently mock).
- **Acceptance:** archive build boots against `dvomzrvslwdabwcwtvrg`; a debug assertion/CI check proves config is embedded.

### B4 — Location claim is fiction; fake distance labels shown in live mode
- Zero CoreLocation/MapKit anywhere; `PrivacyInfo.xcprivacy` declares no location; the "map" is decorative `FakeMap.swift`. Notes claim coordinates are "jittered" — Apple can read the privacy manifest and will see the contradiction (2.3.1).
- Worse: `SupabaseMatchService.swift:96-102` backfills the LIVE candidate list with `Candidate.samples` (fake profiles with fake "km" distances) whenever the DB returns few rows — the reviewer, on an empty network, will see mostly fake people.
- **Requirement:** rewrite the location paragraph truthfully (stronger story: *no location is collected at all*); stop backfilling sample candidates in live mode (or label them as demo content); remove fake distance labels from live surfaces.
- **Acceptance:** notes match the privacy manifest; live Discover shows only real rows (or clearly-marked onboarding content).

### B5 — Client ↔ schema drift; live DB is missing migrations
- Client chat uses `sender_id`/`recipient_id` (`SupabaseChatService.swift:60-67,166-175`); repo migrations define `conversation_id`-based messages with RLS on conversation membership (`0001:83-91`, `0004:66,72`). Live probe (unauth, harmless) confirmed `purge_conversation_with` RPC absent on `dvomzrvslwdabwcwtvrg` (PGRST202); prior note says messages table itself was missing.
- `delete-account/index.ts:55-58` deletes messages by `recipient_id` — a column the repo schema doesn't have — and never checks the result: **account deletion would silently not purge messages** (claim #4 at risk).
- **Requirement:** one canonical messages schema (client shape vs repo migrations reconciled), applied deliberately to the live project — respecting the open `mangasm-backend` migration-lineage hazard — then `delete-account` fixed to match and deployed.
- **Acceptance:** on live: send DM → block → thread purged; delete account → auth user gone and owned rows gone (verified by query, not assumed).

## Confirmed MAJORS (fix before submit if time allows; else must be re-worded in notes)

- **M1 Inbox rehydration ignores blocks** — `SupabaseChatService.loadFromServer:47-113` rebuilds the inbox with no block filter; messages RLS doesn't check `blocks`; a blocked user's thread returns on next launch and they can keep sending. Fix: filter via BlockPolicy on load + `NOT EXISTS` blocks check in messages insert RLS.
- **M2 Block is one-directional in practice** — BlockPolicy is written bidirectional but both live loaders only fetch `blocker_id = viewer` edges (`SupabaseMatchService.swift:109-114`, `SupabaseSafetyService.swift:51-60`) and RLS only exposes self rows.
- **M3 Blocked candidate not removed from Discover until full reload** — block only mutates SafetyService state; MatchService cache untouched (`MatchDetailScreen.swift:70`, applied only in `loadFromServer:94`).
- **M4 Reports: wrong note + schema drift + silent failure** — no `file-report` function in this repo (one exists in sibling `mangasm-backend` with a different shape); reports are direct inserts where the primary shape (`reported_id`) can't match the repo schema (`target_id`, `0002:21`) and every error is swallowed (`SupabaseSafetyService.swift:43-45,90-132`). Fix column shape against the LIVE schema, surface failures, correct the note.
- **M5 verify-purchase hardening** — skips Apple verification entirely when `APPLE_ISSUER_ID/KEY_ID/PRIVATE_KEY` are unset (`index.ts:117-122`) and never validates product IDs against the two ASC products (`index.ts:85`). Fix: set env vars on live + add product-ID allowlist.

## Minors (defer to 1.1.1 unless trivial)

- Report submission gives the user no failure feedback (fire-and-forget `try?`).
- Verify every UGC surface (Events/Communities if reachable) has the Report/Block menu — Discover cards confirmed covered via MatchDetailScreen sheet.

## Verified-true claims (no action)

- Report + Block ARE reachable from both chat overflow (`ChatThreadScreen.swift:223`) and match detail (`MatchDetailScreen.swift:80`); Discover cards route into MatchDetailScreen.
- `ITSAppUsesNonExemptEncryption` NO, Team ID `854XZ2543V`, SIWA entitlement present.
- StoreKit product IDs match ASC (`Mangasm2cute4u001`, `Mangasm0001`); no Stripe reachable from iOS target.
- 85/85 tests pass.

## Out-of-band gates (human)

- ASC login in Chrome (F-SESSION) → then: screenshots upload (staged at `~/dev/asc-mangasm/screenshots/`), App Privacy label, age-rating verify, IAP attachment, review-info fields.
- `supabase login` → live schema inspection (read-only first), then migration + `delete-account` deploy.
- Demo account creation (after B2 ships) + clean-install login test.

## Open questions

1. **B5 canonical schema:** reconcile toward the client's `sender_id/recipient_id` flat shape (smaller change, matches live code) or the migrations' `conversation_id` model (better RLS)? Needs a read-only look at the live schema first.
2. **B1 filter depth for v1:** client denylist + DB trigger, or is client-side only acceptable for the ASAP window?
3. **B2 shape:** full email sign-up flow, or sign-in-only (account provisioned server-side) for the reviewer?
4. **B4:** drop sample backfill entirely, or keep with an explicit "demo profile" badge?

## Risks

- Applying migrations to the live project intersects the open `mangasm-backend` lineage hazard — nothing gets applied without a live-schema diff first.
- ASAP timeline vs five blockers: B1+B2 are the two Apple tests with certainty; B3 gates everything (if the archive is mock, nothing else matters).
