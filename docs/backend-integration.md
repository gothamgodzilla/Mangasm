# Mangasm — Backend Integration Plan (mock → real)

The app talks only to the protocols in `Sources/MangasmApp/Services/Protocols.swift`.
Going live = providing real implementations of those protocols and injecting a
`AppEnvironment.live` instead of `.mock`. **No view code changes.**

## Status / authorization gate

- Schema authored at `supabase/migrations/0001_mangasm_init.sql` — **NOT applied.**
- A Supabase project is connected to this workspace
  (`https://hcpzbxplnkyythzwkovy.supabase.co`), but it looks like a real/shared
  project. **Applying migrations or wiring keys to it requires the owner's
  explicit go-ahead** (which project, prod vs. a fresh dev project). Do not point
  DDL at production on inferred intent.

## Protocol → backend mapping

| Protocol | Supabase backing |
|---|---|
| `AuthService.enter()` | Sign in with Apple / Google / phone-OTP via Supabase Auth (`supabase.auth`). Replace the stub buttons with real provider flows. |
| `ProfileService.current()/update(_:)` | `profiles` table (RLS: owner-write, authed-read). `visibility` jsonb column. |
| `MatchService.featured()/nearby()/refresh()` | `profiles` + `likes`; mutual like → `matches` (trigger). Nearby via PostGIS or a simple distance RPC. |
| `ChatService.conversations()/messages(for:)/send(_:to:)/conversation(for:)` | `conversations` + `messages` (RLS: participants only). Realtime subscribe for live messages + unread. |
| `EventService.events()/communities()/rsvp(_:)` | `events`, `event_rsvps`, `communities`, `community_members`. Approval flow honored via `event_privacy` + `rsvp_status`. |
| `ReputationService.score(for:)/canViewPhotos(viewerScore:targetGate:)` | `profiles.rep_score` + `vouches`. Photo gate enforced both client-side and via an RLS policy / signed-URL RPC for the photos bucket. |
| Premium (M+) | **Stripe** (not RevenueCat) — checkout via a Supabase Edge Function; webhook sets `profiles.premium`. Gates extended bio (600), fetishes visibility, event hosting. |

## Steps to go live (when authorized)

1. Pick/confirm the target Supabase project (prefer a fresh dev project first).
2. Apply `0001_mangasm_init.sql` (Supabase CLI `db push`, or MCP `apply_migration`).
3. Add the `supabase-swift` SDK to `Package.swift`; create `Sources/MangasmApp/Services/Live/`
   with `SupabaseAuthService`, `SupabaseProfileService`, … conforming to the existing protocols.
4. Add `AppEnvironment.live(client:)`; inject it in `MangasmRootView` behind a build flag
   (keep `.mock` for previews/tests).
5. Storage: private `photos` bucket + signed URLs gated by reputation.
6. Stripe: Edge Function for checkout + webhook → `profiles.premium`.
7. Realtime: subscribe to `messages` for the active conversation; recompute unread.

## Safety (non-negotiable, already reflected in schema)

- Event hosting records `consent_ack`; approval-required events gate location reveal.
- Messages/conversations are participant-only (RLS). Photos are reputation-gated.
- All writes scoped to `auth.uid()`.
