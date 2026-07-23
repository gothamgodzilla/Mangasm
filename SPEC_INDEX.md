# SPEC_INDEX — canonical cross-references for com.mangasm.app

Created 2026-07-23 from the spec-panel consistency review. Purpose: one place where
environments, decisions, and App Review claims are reconciled. **If a sibling document
disagrees with this file, this file wins — fix the sibling.**

## Documents in force

| Document                                                             | Role                                                                                                                         |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `docs/superpowers/specs/2026-06-21-mangasm-launch-and-app-design.md` | UI/UX design spec                                                                                                            |
| `docs/superpowers/specs/2026-06-21-mangasm-phase1-auth-spec.md`      | Auth + account lifecycle (amended 2026-07-23: B3 fallback scoping, email/password demo login)                                |
| `docs/superpowers/specs/2026-06-21-mangasm-production-roadmap.md`    | Phase sequencing + decision log A–D                                                                                          |
| `docs/pdca/review-polish/plan.md`                                    | Active submission plan: blockers B1–B5, majors M1–M5                                                                         |
| `APP_REVIEW_NOTES.md`                                                | **Downstream rendering only** — paste-into-ASC text. Never a requirements source; every claim must trace to a spec row below |
| `README.md`                                                          | Contributor onboarding                                                                                                       |

## Environments (Supabase)

| Ref                    | Role                                                                                | DDL policy                                                                |
| ---------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `dvomzrvslwdabwcwtvrg` | **LIVE / production** — the app ships against this (INFRA_SYNC.md is authoritative) | Deliberate, backed-up migrations only; live-schema diff first (B5 hazard) |
| `pwmddvigardiyhqtihdw` | Dev (June roadmap)                                                                  | Free to migrate                                                           |
| `hcpzbxplnkyythzwkovy` | Shared/legacy                                                                       | **NO DDL ever** (roadmap rule)                                            |

The June roadmap predates the live ref; where it says "dev project," B5 work targets **live** with the stated safeguards. The sibling `mangasm-backend` repo's migration lineage conflicts with `supabase/` here — nothing from that repo gets applied (open hazard).

## Decision log

| #   | Date       | Decision                                                                           | Status                                                                                                                                                                                                                                                                                                                                     |
| --- | ---------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| A   | 2026-06-21 | Dual distribution: clean iOS shell + explicit web surface                          | In force                                                                                                                                                                                                                                                                                                                                   |
| B   | 2026-06-21 | Build real E2E for DMs; set `ITSAppUsesNonExemptEncryption = YES`; file France ERN | **Amended 2026-07-23:** E2E shipped (`MessageCrypto.swift`, CryptoKit Curve25519 sealed box, standard algorithms only). Flag stays **NO** on the standard/exempt-algorithm basis; APP_REVIEW_NOTES rewritten to state E2E truthfully. **France ERN filing = open external item (user), confirm exemption stance before review submission** |
| C   | 2026-06-21 | Moderation provider                                                                | OPEN                                                                                                                                                                                                                                                                                                                                       |
| D   | 2026-06-22 | HIV/health data removed app-wide; never reintroduce                                | In force                                                                                                                                                                                                                                                                                                                                   |
| Q1  | open       | B5 canonical chat schema: flat `sender_id/recipient_id` vs `conversation_id`       | Blocked on read-only live-schema look (`supabase login`)                                                                                                                                                                                                                                                                                   |
| Q2  | open       | B1 filter depth for v1: client denylist only vs + DB trigger                       | User decision                                                                                                                                                                                                                                                                                                                              |
| Q3  | open       | B2 shape: sign-in-only vs full email sign-up                                       | User decision (sign-in-only recommended)                                                                                                                                                                                                                                                                                                   |
| Q4  | open       | B4: drop sample backfill vs "demo profile" badge                                   | User decision — must pair with seeded content so reviewer's Discover isn't empty                                                                                                                                                                                                                                                           |

## App Review claim traceability (Guideline 1.2 + metadata)

| Claim (APP_REVIEW_NOTES)                       | Owning spec                        | Code                                                                            | Test                                    | Status 2026-07-23                                           |
| ---------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------- | ----------------------------------------------------------- |
| 1. Content filtering on profiles + messages    | review-polish B1                   | **none — does not exist**                                                       | none                                    | ❌ B1 open                                                  |
| 2. Report reachable; sent to `file-report` fn  | review-polish M4                   | direct inserts, schema drift, errors swallowed                                  | `SafetyMappingTests` (mapping only)     | ⚠️ reachable ✅, note's `file-report` claim false           |
| 3. Block removes thread + filters discovery    | review-polish M1–M3                | `BlockPolicy` + `SupabaseSafetyService`                                         | `DomainLogicTests` block tests          | ⚠️ session-block works; rehydration/bidirectional gaps open |
| 4. Delete account purges backend               | review-polish B5                   | `delete-account/index.ts` (references nonexistent column)                       | `AccountDeletionLogicTests` (mock only) | ❌ B5 open                                                  |
| Demo email/password login                      | phase1-auth §4a (added 2026-07-23) | **none**                                                                        | none                                    | ❌ B2 open                                                  |
| Location: no GPS collected                     | review-polish B4                   | no CoreLocation anywhere ✅, but fake distance labels + sample backfill in live | —                                       | ❌ notes paragraph still claims "jitter"; B4 open           |
| Encryption: HTTPS + E2E DMs, exempt algorithms | Decision B (amended)               | `MessageCrypto.swift`                                                           | `MessageCryptoTests` (4/4)              | ✅ notes + flag reconciled 2026-07-23; ERN question open    |
| StoreKit-only payments, product IDs            | roadmap Phase 3                    | `StoreKitStore.swift`                                                           | `ComplianceTests`                       | ✅ verified                                                 |

## Standing rules

- `APP_REVIEW_NOTES.md` changes only as a consequence of a spec/code change — cite the row here.
- Any new Supabase ref, decision, or reviewer-facing claim gets a row in this file in the same PR.
- Build bumps (`ci/ios-build-N`) should state in the commit body which blocker rows changed status (none is acceptable but must be intentional).
