-- Mangasm — cartoon-character referral program
-- Each member gets a unique classic-cartoon code (TWEETY, TAZ, ELMERFUDD, …).
-- 5 successful signups → 1 free month M+ (~$20 value via subscription_expires_at).

-- ── Profile referral fields ───────────────────────────────────────────────────
alter table profiles
  add column if not exists referral_code text unique,
  add column if not exists referred_by uuid references profiles (id) on delete set null,
  add column if not exists referral_count integer not null default 0,
  add column if not exists referral_rewards_earned integer not null default 0,
  add column if not exists subscription_expires_at timestamptz,
  add column if not exists premium boolean not null default false;

create index if not exists profiles_referral_code_idx on profiles (referral_code);

-- ── Referral ledger ───────────────────────────────────────────────────────────
create table if not exists referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references profiles (id) on delete cascade,
  referred_id uuid not null references profiles (id) on delete cascade,
  code_used text not null,
  status text not null default 'pending'
    check (status in ('pending', 'completed', 'fraud', 'revoked')),
  reward_granted boolean not null default false,
  fraud_flags text[] not null default '{}',
  ip_hash text,
  device_fp text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint referrals_referred_unique unique (referred_id),
  constraint referrals_no_self check (referrer_id <> referred_id)
);

create index if not exists referrals_referrer_idx on referrals (referrer_id, status);
create index if not exists referrals_code_idx on referrals (code_used);

alter table referrals enable row level security;

create policy referrals_read_own on referrals for select to authenticated
  using (auth.uid() = referrer_id or auth.uid() = referred_id);

-- ── Cartoon code pool (display names → uppercase codes) ───────────────────────
create table if not exists cartoon_referral_codes (
  code text primary key,
  display_name text not null,
  franchise text not null default 'classic',
  sort_order int not null default 0
);

insert into cartoon_referral_codes (code, display_name, franchise, sort_order) values
  ('TWEETY',       'Tweety',           'Looney Tunes', 1),
  ('TAZ',          'Taz',              'Looney Tunes', 2),
  ('ELMERFUDD',    'Elmer Fudd',       'Looney Tunes', 3),
  ('BUGS',         'Bugs Bunny',       'Looney Tunes', 4),
  ('DAFFY',        'Daffy Duck',       'Looney Tunes', 5),
  ('PORKY',        'Porky Pig',        'Looney Tunes', 6),
  ('SYLVESTER',    'Sylvester',        'Looney Tunes', 7),
  ('ROADRUNNER',   'Road Runner',      'Looney Tunes', 8),
  ('WILEY',        'Wile E. Coyote',   'Looney Tunes', 9),
  ('FOGHORN',      'Foghorn Leghorn',  'Looney Tunes', 10),
  ('TOM',          'Tom',              'Tom & Jerry', 11),
  ('JERRY',        'Jerry',            'Tom & Jerry', 12),
  ('SCOOBY',       'Scooby-Doo',       'Hanna-Barbera', 13),
  ('SHAGGY',       'Shaggy',           'Hanna-Barbera', 14),
  ('FLINTSTONE',   'Fred Flintstone',  'Hanna-Barbera', 15),
  ('BARNEY',       'Barney Rubble',    'Hanna-Barbera', 16),
  ('YOGI',         'Yogi Bear',        'Hanna-Barbera', 17),
  ('BOOBOO',       'Boo-Boo',          'Hanna-Barbera', 18),
  ('ASTRO',        'Astro',            'The Jetsons', 19),
  ('GEORGE',       'George Jetson',    'The Jetsons', 20),
  ('WOODPECKER',   'Woody Woodpecker','Woody Woodpecker', 21),
  ('PHOOEY',       'Hong Kong Phooey', 'Hanna-Barbera', 22),
  ('PEPE',         'Pepe Le Pew',      'Looney Tunes', 23),
  ('MARVIN',       'Marvin the Martian','Looney Tunes', 24),
  ('TWEETYBIRD',   'Tweety Bird',      'Looney Tunes', 25)
on conflict (code) do nothing;

-- ── Assign next available cartoon code to a profile ───────────────────────────
create or replace function assign_cartoon_referral_code(p_user_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  base_code text;
  candidate text;
  suffix int := 0;
begin
  if exists (select 1 from profiles where id = p_user_id and referral_code is not null) then
    return (select referral_code from profiles where id = p_user_id);
  end if;

  for base_code in
    select c.code from cartoon_referral_codes c
    order by c.sort_order, c.code
  loop
    candidate := base_code;
    if not exists (select 1 from profiles where referral_code = candidate) then
      update profiles set referral_code = candidate where id = p_user_id;
      return candidate;
    end if;
  end loop;

  -- Pool exhausted — append numeric suffix to first code
  base_code := (select code from cartoon_referral_codes order by sort_order limit 1);
  loop
    suffix := suffix + 1;
    candidate := base_code || suffix::text;
    exit when not exists (select 1 from profiles where referral_code = candidate);
  end loop;

  update profiles set referral_code = candidate where id = p_user_id;
  return candidate;
end;
$$;

-- ── Grant 1 free month M+ per 5 completed referrals (~$20 value) ──────────────
create or replace function grant_referral_subscription_reward(p_referrer_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  completed int;
  already int;
  new_expires timestamptz;
  months_to_grant int;
begin
  select count(*)::int into completed
  from referrals
  where referrer_id = p_referrer_id and status = 'completed';

  select coalesce(referral_rewards_earned, 0) into already
  from profiles where id = p_referrer_id;

  months_to_grant := completed / 5 - already;
  if months_to_grant <= 0 then
    return jsonb_build_object('granted', false, 'completed', completed, 'reason', 'threshold_not_met');
  end if;

  select greatest(
    coalesce(subscription_expires_at, now()),
    now()
  ) + (months_to_grant * interval '30 days')
  into new_expires
  from profiles where id = p_referrer_id;

  update profiles set
    subscription_expires_at = new_expires,
    premium = true,
    referral_rewards_earned = already + months_to_grant
  where id = p_referrer_id;

  update referrals set reward_granted = true
  where referrer_id = p_referrer_id
    and status = 'completed'
    and reward_granted = false;

  return jsonb_build_object(
    'granted', true,
    'months_granted', months_to_grant,
    'completed_referrals', completed,
    'subscription_expires_at', new_expires,
    'value_usd', months_to_grant * 20
  );
end;
$$;

-- ── Record a signup against a referrer code ───────────────────────────────────
create or replace function record_referral_signup(
  p_code text,
  p_referred_id uuid,
  p_ip_hash text default null,
  p_device_fp text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text := upper(trim(p_code));
  v_referrer_id uuid;
  v_fraud text[] := '{}';
  v_reward jsonb;
begin
  if p_referred_id is null or v_code = '' then
    raise exception 'invalid_referral_input';
  end if;

  select id into v_referrer_id
  from profiles
  where upper(referral_code) = v_code;

  if v_referrer_id is null then
    raise exception 'invalid_referral_code';
  end if;

  if v_referrer_id = p_referred_id then
    raise exception 'self_referral';
  end if;

  if exists (select 1 from referrals where referred_id = p_referred_id) then
    raise exception 'already_referred';
  end if;

  if p_ip_hash is not null and (
    select count(*) from referrals
    where ip_hash = p_ip_hash
      and created_at > now() - interval '30 days'
  ) >= 3 then
    v_fraud := array_append(v_fraud, 'ip_cluster');
  end if;

  if p_device_fp is not null and (
    select count(*) from referrals
    where device_fp = p_device_fp
      and created_at > now() - interval '30 days'
  ) >= 2 then
    v_fraud := array_append(v_fraud, 'device_fingerprint');
  end if;

  insert into referrals (
    referrer_id, referred_id, code_used, status, fraud_flags, ip_hash, device_fp, completed_at
  ) values (
    v_referrer_id,
    p_referred_id,
    v_code,
    case when cardinality(v_fraud) > 0 then 'fraud' else 'completed' end,
    v_fraud,
    p_ip_hash,
    p_device_fp,
    case when cardinality(v_fraud) > 0 then null else now() end
  );

  update profiles set referred_by = v_referrer_id where id = p_referred_id;

  if cardinality(v_fraud) = 0 then
    update profiles set referral_count = referral_count + 1 where id = v_referrer_id;
    v_reward := grant_referral_subscription_reward(v_referrer_id);
  else
    v_reward := jsonb_build_object('granted', false, 'reason', 'fraud_flags', 'flags', v_fraud);
  end if;

  return jsonb_build_object(
    'ok', true,
    'code', v_code,
    'referrer_id', v_referrer_id,
    'fraud_flags', v_fraud,
    'reward', v_reward
  );
end;
$$;

-- Auto-assign cartoon code when profile row is created
create or replace function profiles_assign_referral_code()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform assign_cartoon_referral_code(new.id);
  return new;
end;
$$;

drop trigger if exists trg_profiles_assign_referral_code on profiles;
create trigger trg_profiles_assign_referral_code
  after insert on profiles
  for each row
  when (new.referral_code is null)
  execute function profiles_assign_referral_code();

-- Backfill missing codes for existing profiles
do $$
declare r record;
begin
  for r in select id from profiles where referral_code is null loop
    perform assign_cartoon_referral_code(r.id);
  end loop;
end;
$$;