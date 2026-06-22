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
    into          text[] not null default '{}',
    hiv           text default '',
    last_tested   text default '',
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
        "hiv": true, "socials": true, "instagram": true, "x": true,
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
