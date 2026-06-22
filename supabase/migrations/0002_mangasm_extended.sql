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
