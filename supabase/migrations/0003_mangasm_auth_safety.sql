-- Mangasm — migration 0003: account lifecycle + safety triggers + RLS hardening
-- Applies after 0002. Addresses verified gaps:
--   * mutual-like -> match trigger (was a comment in 0001)
--   * vouch -> reputation_scores + profiles.rep_score sync (was a comment in 0002)
--   * profiles DELETE policy (App Store account deletion, Guideline 5.1.1(v))
--   * consent_log + deletion_requests (EULA / 18+ / sensitive-data consent)
--   * sensitive profile fields (hiv, into, socials) masked from non-owners

-- ── consent_log (EULA, 18+ affirmation, sensitive-data disclosure) ──────────
create table if not exists consent_log (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references profiles (id) on delete cascade,
    kind       text not null check (kind in
                 ('eula', 'age_18plus', 'hiv_disclosure', 'orientation_disclosure')),
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
-- OTHER users through this view, which reveals hiv / into / socials only to the
-- owner. security_invoker => the querying user's RLS still applies.
create or replace view profile_cards
with (security_invoker = true) as
select
    p.id, p.name, p.age, p.location, p.headline, p.bio, p.hobbies, p.position,
    p.astro, p.chinese, p.life_path, p.avatar_url, p.photos,
    p.vouches, p.rep_score, p.ai_match, p.premium, p.visibility,
    p.created_at, p.updated_at,
    case when p.id = auth.uid() then p."into"      else '{}'::text[] end as "into",
    case when p.id = auth.uid() then p.hiv         else '' end          as hiv,
    case when p.id = auth.uid() then p.last_tested else '' end          as last_tested,
    case when p.id = auth.uid() then p.instagram   else '' end          as instagram,
    case when p.id = auth.uid() then p.x_handle    else '' end          as x_handle
from profiles p;

notify pgrst, 'reload schema';
