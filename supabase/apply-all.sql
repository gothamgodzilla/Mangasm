-- Mangasm — combined schema apply (migrations 0001 + 0002 + 0003).
-- Paste into Supabase Dashboard → SQL Editor → Run. Real Supabase already
-- provides auth.users / auth.uid() / the authenticated|anon roles.

-- ========================= 0001 =========================
-- Mangasm — initial schema (safety-first gay dating app)
-- Maps the app's mock service protocols onto Postgres + RLS.
-- STATUS: NOT YET APPLIED. Apply against a chosen project only with explicit
-- owner authorization (see docs/backend-integration.md). Designed for Supabase
-- (assumes auth.users exists).

-- ─────────────────────────────────────────────────────────────────────────
-- Enums
-- ─────────────────────────────────────────────────────────────────────────
-- Event taxonomy uses App-Store-safe labels (Guideline 1.1.4): the concept is
-- preserved, the strings are clean. Mirrors the Swift EventType enum raw values.
create type event_type as enum ('open_door', 'social_mixer', 'circle', 'cosplay');
create type event_privacy as enum ('approval', 'open');
create type rsvp_status as enum ('none', 'requested', 'confirmed', 'declined');

-- ─────────────────────────────────────────────────────────────────────────
-- profiles  (ProfileService)
-- One row per auth user. Visibility flags live in `visibility` jsonb.
-- ─────────────────────────────────────────────────────────────────────────
create table profiles (
    id            uuid primary key references auth.users (id) on delete cascade,
    name          text not null default '',
    age           int  check (age is null or (age >= 18 and age <= 120)),
    location      text default '',
    headline      text default '',
    bio           text default '',
    hobbies       text[] not null default '{}',
    position      text default '',
    "into"        text[] not null default '{}',   -- quoted: INTO is a reserved word
    instagram     text default '',
    x_handle      text default '',
    astro         text default '',
    chinese       text default '',
    life_path     int,
    avatar_url    text,
    photos        text[] not null default '{}',
    vouches       int not null default 0,
    rep_score     int not null default 0,
    ai_match      numeric not null default 0,
    premium       boolean not null default false,
    visibility    jsonb not null default '{
        "headline": true, "hobbies": true, "position": true, "into": false,
        "socials": true, "instagram": true, "x": true,
        "anthem": true, "photos": true
    }'::jsonb,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────
-- likes + matches  (MatchService)
-- A match exists when two users like each other (enforced by trigger).
-- ─────────────────────────────────────────────────────────────────────────
create table likes (
    liker_id  uuid not null references profiles (id) on delete cascade,
    liked_id  uuid not null references profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (liker_id, liked_id),
    check (liker_id <> liked_id)
);

create table matches (
    id        uuid primary key default gen_random_uuid(),
    user_a    uuid not null references profiles (id) on delete cascade,
    user_b    uuid not null references profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    check (user_a < user_b),
    unique (user_a, user_b)
);

-- ─────────────────────────────────────────────────────────────────────────
-- conversations + messages  (ChatService)
-- ─────────────────────────────────────────────────────────────────────────
create table conversations (
    id        uuid primary key default gen_random_uuid(),
    user_a    uuid not null references profiles (id) on delete cascade,
    user_b    uuid not null references profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    check (user_a < user_b),
    unique (user_a, user_b)
);

create table messages (
    id              uuid primary key default gen_random_uuid(),
    conversation_id uuid not null references conversations (id) on delete cascade,
    sender_id       uuid not null references profiles (id) on delete cascade,
    body            text not null,
    created_at      timestamptz not null default now(),
    read_at         timestamptz
);
create index messages_conversation_idx on messages (conversation_id, created_at);

-- ─────────────────────────────────────────────────────────────────────────
-- events + rsvps  (EventService) — safety-first: approval flow + consent
-- ─────────────────────────────────────────────────────────────────────────
create table events (
    id          uuid primary key default gen_random_uuid(),
    host_id     uuid not null references profiles (id) on delete cascade,
    type        event_type not null,
    title       text not null,
    description text not null default '',
    when_text   text not null default '',
    place       text not null default '',
    area        text not null default '',
    capacity    int  not null default 0,
    privacy     event_privacy not null default 'approval',
    consent_ack boolean not null default false,   -- host accepted safety/consent code
    created_at  timestamptz not null default now()
);

create table event_rsvps (
    event_id uuid not null references events (id) on delete cascade,
    user_id  uuid not null references profiles (id) on delete cascade,
    status   rsvp_status not null default 'requested',
    created_at timestamptz not null default now(),
    primary key (event_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────────
-- communities  (EventService.communities)
-- ─────────────────────────────────────────────────────────────────────────
create table communities (
    id           uuid primary key default gen_random_uuid(),
    name         text not null,
    tagline      text not null default '',
    monogram     text not null default '',
    member_count int  not null default 0,
    created_at   timestamptz not null default now()
);

create table community_members (
    community_id uuid not null references communities (id) on delete cascade,
    user_id      uuid not null references profiles (id) on delete cascade,
    primary key (community_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────────
-- vouches + reputation  (ReputationService)
-- rep_score is denormalized onto profiles; photos are reputation-gated in app
-- (a viewer with rep_score >= a target's gate may view photos).
-- ─────────────────────────────────────────────────────────────────────────
create table vouches (
    voucher_id uuid not null references profiles (id) on delete cascade,
    vouchee_id uuid not null references profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (voucher_id, vouchee_id),
    check (voucher_id <> vouchee_id)
);

-- ─────────────────────────────────────────────────────────────────────────
-- Row Level Security
-- ─────────────────────────────────────────────────────────────────────────
alter table profiles          enable row level security;
alter table likes             enable row level security;
alter table matches           enable row level security;
alter table conversations     enable row level security;
alter table messages          enable row level security;
alter table events            enable row level security;
alter table event_rsvps       enable row level security;
alter table communities       enable row level security;
alter table community_members enable row level security;
alter table vouches           enable row level security;

-- profiles: any authenticated user may read; only the owner may write their row.
create policy profiles_read  on profiles for select to authenticated using (true);
create policy profiles_write on profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy profiles_insert on profiles for insert to authenticated with check (auth.uid() = id);

-- likes: a user manages their own likes.
create policy likes_rw on likes for all to authenticated using (auth.uid() = liker_id) with check (auth.uid() = liker_id);

-- matches: visible only to participants.
create policy matches_read on matches for select to authenticated using (auth.uid() = user_a or auth.uid() = user_b);

-- conversations: only participants.
create policy conversations_read on conversations for select to authenticated using (auth.uid() = user_a or auth.uid() = user_b);

-- messages: only conversation participants may read; sender must be self.
create policy messages_read on messages for select to authenticated using (
    exists (select 1 from conversations c where c.id = conversation_id
            and (c.user_a = auth.uid() or c.user_b = auth.uid())));
create policy messages_send on messages for insert to authenticated with check (
    sender_id = auth.uid() and exists (
        select 1 from conversations c where c.id = conversation_id
        and (c.user_a = auth.uid() or c.user_b = auth.uid())));

-- events: readable by all authenticated; host manages their own.
create policy events_read on events for select to authenticated using (true);
create policy events_write on events for all to authenticated using (auth.uid() = host_id) with check (auth.uid() = host_id);

-- rsvps: a user manages their own rsvp; hosts can read their event's rsvps.
create policy rsvps_self on event_rsvps for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy rsvps_host_read on event_rsvps for select to authenticated using (
    exists (select 1 from events e where e.id = event_id and e.host_id = auth.uid()));

-- communities: world-readable to authenticated; membership self-managed.
create policy communities_read on communities for select to authenticated using (true);
create policy members_self on community_members for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- vouches: voucher manages their own; everyone authenticated may read counts.
create policy vouches_read on vouches for select to authenticated using (true);
create policy vouches_write on vouches for all to authenticated using (auth.uid() = voucher_id) with check (auth.uid() = voucher_id);

-- ========================= 0002 =========================
-- Mangasm — extended schema (safety, token economy, video, privacy, travel, matching)
-- Applies after 0001. STATUS: apply to a chosen dev project (see docs/backend-integration.md).

-- ─────────────────────────────────────────────────────────────────────────
-- blocks + reports  (SafetyService — App Store Guideline 1.2 UGC safety)
-- ─────────────────────────────────────────────────────────────────────────
create table blocks (
    blocker_id uuid not null references profiles (id) on delete cascade,
    blocked_id uuid not null references profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (blocker_id, blocked_id),
    check (blocker_id <> blocked_id)
);

create type report_reason as enum ('harassment', 'spam', 'fake_profile', 'underage', 'other');
create type report_status as enum ('open', 'reviewing', 'actioned', 'dismissed');

create table reports (
    id          uuid primary key default gen_random_uuid(),
    reporter_id uuid not null references profiles (id) on delete cascade,
    target_id   uuid not null references profiles (id) on delete cascade,
    reason      report_reason not null,
    details     text default '',
    status      report_status not null default 'open',
    created_at  timestamptz not null default now(),
    check (reporter_id <> target_id)
);
create index reports_target_idx on reports (target_id, status);

-- ─────────────────────────────────────────────────────────────────────────
-- reputation_scores  (ReputationService — normalized source of truth)
-- profiles.rep_score stays as a denormalized read cache, synced from here.
-- ─────────────────────────────────────────────────────────────────────────
create table reputation_scores (
    user_id     uuid primary key references profiles (id) on delete cascade,
    score       int  not null default 0,
    tier        text not null default 'new',     -- new/rising/veteran/elite/legend
    vouch_count int  not null default 0,
    photo_gate  int  not null default 50,         -- min viewer score to see photos
    updated_at  timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────
-- token_transactions  (Mangasm Coins "MGC" economy — the "4.2k MGC" in the UI)
-- Ledger; current balance = sum(amount). kind: earn | spend | grant | refund.
-- ─────────────────────────────────────────────────────────────────────────
create type token_kind as enum ('earn', 'spend', 'grant', 'refund');

create table token_transactions (
    id            uuid primary key default gen_random_uuid(),
    user_id       uuid not null references profiles (id) on delete cascade,
    amount        int  not null,                  -- signed: +earn/grant, -spend
    kind          token_kind not null,
    reason        text not null default '',
    balance_after int  not null default 0,
    created_at    timestamptz not null default now()
);
create index token_tx_user_idx on token_transactions (user_id, created_at);

-- ─────────────────────────────────────────────────────────────────────────
-- video_rooms  (gated video dates between matched users)
-- ─────────────────────────────────────────────────────────────────────────
create type video_room_status as enum ('pending', 'live', 'ended', 'declined');

create table video_rooms (
    id         uuid primary key default gen_random_uuid(),
    host_id    uuid not null references profiles (id) on delete cascade,
    guest_id   uuid not null references profiles (id) on delete cascade,
    status     video_room_status not null default 'pending',
    started_at timestamptz,
    ended_at   timestamptz,
    created_at timestamptz not null default now(),
    check (host_id <> guest_id)
);

-- ─────────────────────────────────────────────────────────────────────────
-- privacy_zones  (neighbourhood-level masking; exact location never displayed)
-- ─────────────────────────────────────────────────────────────────────────
create table privacy_zones (
    id            uuid primary key default gen_random_uuid(),
    user_id       uuid not null references profiles (id) on delete cascade,
    label         text not null default '',        -- e.g. "Dubai Marina"
    center_geohash text not null default '',        -- coarse geohash, not lat/long
    radius_m      int  not null default 800,
    active        boolean not null default true,
    created_at    timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────
-- travel_plans  ("Dubai → London" passport / where members are heading)
-- ─────────────────────────────────────────────────────────────────────────
create table travel_plans (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references profiles (id) on delete cascade,
    city       text not null,
    country    text default '',
    arrive_on  date,
    depart_on  date,
    note       text default '',
    created_at timestamptz not null default now()
);
create index travel_user_idx on travel_plans (user_id, arrive_on);

-- ─────────────────────────────────────────────────────────────────────────
-- match_preferences + match_results  (MatchService)
-- ─────────────────────────────────────────────────────────────────────────
create table match_preferences (
    user_id        uuid primary key references profiles (id) on delete cascade,
    min_age        int  not null default 18 check (min_age >= 18),
    max_age        int  not null default 99,
    max_distance_km int not null default 100,
    positions      text[] not null default '{}',
    into_filters   text[] not null default '{}',
    show_me        text not null default 'everyone',
    updated_at     timestamptz not null default now()
);

create table match_results (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid not null references profiles (id) on delete cascade,
    candidate_id uuid not null references profiles (id) on delete cascade,
    score        numeric not null default 0,       -- 0..100 compatibility
    astro_note   text default '',
    num_note     text default '',
    chinese_note text default '',
    computed_at  timestamptz not null default now(),
    unique (user_id, candidate_id),
    check (user_id <> candidate_id)
);
create index match_results_user_idx on match_results (user_id, score desc);

-- ─────────────────────────────────────────────────────────────────────────
-- Row Level Security — every row scoped to its owner.
-- ─────────────────────────────────────────────────────────────────────────
alter table blocks              enable row level security;
alter table reports             enable row level security;
alter table reputation_scores   enable row level security;
alter table token_transactions  enable row level security;
alter table video_rooms         enable row level security;
alter table privacy_zones       enable row level security;
alter table travel_plans        enable row level security;
alter table match_preferences   enable row level security;
alter table match_results       enable row level security;

create policy blocks_self on blocks for all to authenticated
    using (auth.uid() = blocker_id) with check (auth.uid() = blocker_id);

create policy reports_insert on reports for insert to authenticated
    with check (auth.uid() = reporter_id);
create policy reports_read_own on reports for select to authenticated
    using (auth.uid() = reporter_id);

create policy reputation_read on reputation_scores for select to authenticated using (true);
-- writes to reputation_scores happen via service role / triggers only (no user policy).

create policy tokens_read_own on token_transactions for select to authenticated
    using (auth.uid() = user_id);
-- token writes via service role (purchases, grants, spends are server-authoritative).

create policy video_participants on video_rooms for all to authenticated
    using (auth.uid() = host_id or auth.uid() = guest_id)
    with check (auth.uid() = host_id or auth.uid() = guest_id);

create policy zones_self on privacy_zones for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy travel_read on travel_plans for select to authenticated using (true);
create policy travel_write on travel_plans for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy prefs_self on match_preferences for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy results_read_own on match_results for select to authenticated
    using (auth.uid() = user_id);
-- match_results written by the matching engine (service role).

-- Ask PostgREST to reload its schema cache after applying.
notify pgrst, 'reload schema';

-- ========================= 0003 =========================
-- Mangasm — migration 0003: account lifecycle + safety triggers + RLS hardening
-- Applies after 0002. Addresses verified gaps:
--   * mutual-like -> match trigger (was a comment in 0001)
--   * vouch -> reputation_scores + profiles.rep_score sync (was a comment in 0002)
--   * profiles DELETE policy (App Store account deletion, Guideline 5.1.1(v))
--   * consent_log + deletion_requests (EULA / 18+ / sensitive-data consent)
--   * sensitive profile fields (into, socials) masked from non-owners

-- ── consent_log (EULA, 18+ affirmation, sensitive-data disclosure) ──────────
create table if not exists consent_log (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references profiles (id) on delete cascade,
    kind       text not null check (kind in
                 ('eula', 'age_18plus', 'orientation_disclosure')),
    version    text not null default '',
    value      text not null default '',
    created_at timestamptz not null default now()
);
create index consent_log_user_idx on consent_log (user_id, kind);

-- ── deletion_requests (optional disclosed 30-day window) ────────────────────
create table if not exists deletion_requests (
    user_id      uuid primary key references profiles (id) on delete cascade,
    requested_at timestamptz not null default now(),
    purge_after  timestamptz not null default (now() + interval '30 days')
);

-- ── RLS for the new tables + profiles DELETE path ──────────────────────────
alter table consent_log       enable row level security;
alter table deletion_requests enable row level security;

create policy consent_log_own on consent_log for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy deletion_requests_own on deletion_requests for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Users may delete their own profile row (cascades all FK data).
create policy profiles_delete_own on profiles for delete to authenticated
    using (auth.uid() = id);

-- ── Trigger: mutual like -> match ──────────────────────────────────────────
create or replace function create_match_on_mutual_like()
returns trigger language plpgsql as $$
declare a uuid; b uuid;
begin
    if exists (select 1 from likes l
               where l.liker_id = new.liked_id and l.liked_id = new.liker_id) then
        a := least(new.liker_id, new.liked_id);
        b := greatest(new.liker_id, new.liked_id);
        insert into matches (user_a, user_b) values (a, b)
        on conflict (user_a, user_b) do nothing;
    end if;
    return new;
end $$;

drop trigger if exists trg_mutual_like on likes;
create trigger trg_mutual_like after insert on likes
    for each row execute function create_match_on_mutual_like();

-- ── Trigger: vouch -> reputation_scores + profiles.rep_score sync ──────────
create or replace function sync_rep_on_vouch()
returns trigger language plpgsql as $$
declare new_count int; new_score int; new_tier text;
begin
    insert into reputation_scores (user_id, vouch_count, score)
    values (new.vouchee_id, 1, 10)
    on conflict (user_id) do update
        set vouch_count = reputation_scores.vouch_count + 1,
            score       = least(100, (reputation_scores.vouch_count + 1) * 10),
            updated_at  = now()
    returning vouch_count, score into new_count, new_score;

    new_tier := case
        when new_score >= 90 then 'legend'
        when new_score >= 70 then 'elite'
        when new_score >= 40 then 'veteran'
        when new_score >= 20 then 'rising'
        else 'new' end;

    update reputation_scores set tier = new_tier where user_id = new.vouchee_id;
    update profiles set rep_score = new_score, vouches = new_count
        where id = new.vouchee_id;
    return new;
end $$;

drop trigger if exists trg_vouch_rep on vouches;
create trigger trg_vouch_rep after insert on vouches
    for each row execute function sync_rep_on_vouch();

-- ── RLS hardening: mask sensitive profile fields from non-owners ───────────
-- profiles_read stays (base fields needed app-wide), but clients should read
-- OTHER users through this view, which reveals into / socials only to the
-- owner. security_invoker => the querying user's RLS still applies.
create or replace view profile_cards
with (security_invoker = true) as
select
    p.id, p.name, p.age, p.location, p.headline, p.bio, p.hobbies, p.position,
    p.astro, p.chinese, p.life_path, p.avatar_url, p.photos,
    p.vouches, p.rep_score, p.ai_match, p.premium, p.visibility,
    p.created_at, p.updated_at,
    case when p.id = auth.uid() then p."into"      else '{}'::text[] end as "into",
    case when p.id = auth.uid() then p.instagram   else '' end          as instagram,
    case when p.id = auth.uid() then p.x_handle    else '' end          as x_handle
from profiles p;

notify pgrst, 'reload schema';
