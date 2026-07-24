-- =============================================================================
-- 0009_guideline12_safety.sql
-- Mangasm — Guideline 1.2 Safety Suite (user_blocks / content_reports /
-- moderation_events + hardened RPCs)
--
-- ADDITIVE ONLY. Ported verbatim from live schema on hcpzbxplnkyythzwkovy
-- (deployed 2026-07-21) to dvomzrvslwdabwcwtvrg. Fully idempotent — safe to
-- run more than once. Matches the client contract in SafetyService.swift:
--   .from("user_blocks").select("blocked_id")
--   rpc block_user(target uuid)
--   rpc report_content(p_reported_user, p_content_type, p_content_id,
--                      p_reason, p_details)
--   is_blocked_pair(a uuid, b uuid) for server-side feed filtering
--
-- Verification pass (edge cases handled):
--  1. Re-run safety: create table if not exists / create or replace /
--     drop policy if exists guards throughout.
--  2. Self-block: blocked client-side, in RLS with_check, in the no_self_block
--     CHECK constraint, and in block_user() — four layers.
--  3. Double block: PK (blocker_id, blocked_id) + on conflict do nothing.
--  4. Deleted users: FKs to auth.users with on delete cascade / set null.
--  5. anon lockout: execute revoked on all RPCs; table privileges revoked;
--     moderation_events has RLS enabled with NO policies = client-invisible,
--     writable only through SECURITY DEFINER functions.
--  6. Report detail abuse: 2000-char CHECK + left() truncation in the RPC.
-- =============================================================================

-- ---------- 1. TABLES ----------

create table if not exists public.user_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint user_blocks_pkey primary key (blocker_id, blocked_id),
  constraint no_self_block check (blocker_id <> blocked_id)
);

create table if not exists public.content_reports (
  id uuid not null default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reported_user_id uuid references auth.users(id) on delete set null,
  content_type text not null
    constraint content_reports_content_type_check
    check (content_type in ('profile','photo','message','event','bio','other')),
  content_id text,
  reason text not null
    constraint content_reports_reason_check
    check (reason in ('nudity','harassment','spam','impersonation',
                      'underage','violence','scam','other')),
  details text
    constraint content_reports_details_check
    check (char_length(details) <= 2000),
  status text not null default 'pending'
    constraint content_reports_status_check
    check (status in ('pending','actioned','dismissed')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  constraint content_reports_pkey primary key (id)
);

create table if not exists public.moderation_events (
  id bigint generated always as identity,
  kind text not null
    constraint moderation_events_kind_check
    check (kind in ('block','report','unblock')),
  actor_id uuid,
  subject_id uuid,
  ref_id uuid,
  created_at timestamptz not null default now(),
  constraint moderation_events_pkey primary key (id)
);

-- 24-hour moderation SLA query support:
--   select * from content_reports where status='pending'
--     and created_at < now() - interval '20 hours';
create index if not exists idx_content_reports_status_created
  on public.content_reports (status, created_at);

-- ---------- 2. ROW LEVEL SECURITY ----------

alter table public.user_blocks        enable row level security;
alter table public.content_reports    enable row level security;
alter table public.moderation_events  enable row level security;
-- moderation_events: deliberately NO policies — deny-all for clients;
-- rows are written only by the SECURITY DEFINER functions below.

drop policy if exists blocks_select_own on public.user_blocks;
create policy blocks_select_own on public.user_blocks
  for select using (auth.uid() = blocker_id);

drop policy if exists blocks_insert_own on public.user_blocks;
create policy blocks_insert_own on public.user_blocks
  for insert with check (auth.uid() = blocker_id and blocker_id <> blocked_id);

drop policy if exists blocks_delete_own on public.user_blocks;
create policy blocks_delete_own on public.user_blocks
  for delete using (auth.uid() = blocker_id);

drop policy if exists reports_select_own on public.content_reports;
create policy reports_select_own on public.content_reports
  for select using (auth.uid() = reporter_id);

drop policy if exists reports_insert_own on public.content_reports;
create policy reports_insert_own on public.content_reports
  for insert with check (auth.uid() = reporter_id);

-- ---------- 3. RPCs (SECURITY DEFINER, search_path pinned) ----------

create or replace function public.block_user(target uuid)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if target is null or target = auth.uid() then raise exception 'invalid block target'; end if;
  insert into public.user_blocks (blocker_id, blocked_id)
    values (auth.uid(), target)
    on conflict do nothing;
  insert into public.moderation_events (kind, actor_id, subject_id)
    values ('block', auth.uid(), target);
end;
$function$;

create or replace function public.report_content(
  p_reported_user uuid,
  p_content_type  text,
  p_content_id    text,
  p_reason        text,
  p_details       text default null
)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $function$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  insert into public.content_reports
      (reporter_id, reported_user_id, content_type, content_id, reason, details)
    values
      (auth.uid(), p_reported_user, p_content_type, p_content_id, p_reason,
       nullif(left(coalesce(p_details, ''), 2000), ''))
    returning id into v_id;
  insert into public.moderation_events (kind, actor_id, subject_id, ref_id)
    values ('report', auth.uid(), p_reported_user, v_id);
  return v_id;
end;
$function$;

create or replace function public.is_blocked_pair(a uuid, b uuid)
returns boolean
language sql
stable
set search_path to 'public'
as $function$
  select exists (
    select 1 from public.user_blocks
    where (blocker_id = a and blocked_id = b)
       or (blocker_id = b and blocked_id = a)
  );
$function$;

-- ---------- 4. PRIVILEGE HARDENING ----------

-- Tables: clients never touch these except through RLS'd select/insert/delete
-- on their own rows; anon gets nothing at all.
revoke all on table public.user_blocks       from anon;
revoke all on table public.content_reports   from anon;
revoke all on table public.moderation_events from anon, authenticated;

grant select, insert, delete on table public.user_blocks     to authenticated;
grant select, insert         on table public.content_reports to authenticated;

-- Functions: signed-in users only. Default PUBLIC execute is revoked.
revoke all on function public.block_user(uuid)                          from public, anon;
revoke all on function public.report_content(uuid,text,text,text,text)  from public, anon;
revoke all on function public.is_blocked_pair(uuid,uuid)                from public, anon;

grant execute on function public.block_user(uuid)                         to authenticated;
grant execute on function public.report_content(uuid,text,text,text,text) to authenticated;
grant execute on function public.is_blocked_pair(uuid,uuid)               to authenticated;

-- ---------- 5. POST-APPLY VERIFICATION (run separately; read-only) ----------
-- select
--   (select count(*) from information_schema.tables
--     where table_schema='public'
--       and table_name in ('user_blocks','content_reports','moderation_events'))
--         as safety_tables,                                        -- expect 3
--   has_function_privilege('anon','public.block_user(uuid)','execute')
--         as anon_can_block,                                       -- expect f
--   has_function_privilege('authenticated','public.block_user(uuid)','execute')
--         as auth_can_block,                                       -- expect t
--   has_function_privilege('authenticated',
--     'public.report_content(uuid,text,text,text,text)','execute')
--         as auth_can_report;                                      -- expect t
