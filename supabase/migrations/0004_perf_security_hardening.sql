-- Mangasm — migration 0004: performance + security hardening
-- Resolves Supabase advisor findings after 0001–0003:
--   * auth_rls_initplan (WARN, perf): wrap auth.uid() in (select auth.uid())
--     so it is evaluated once per query instead of once per row (5–100x on scale).
--   * unindexed_foreign_keys (INFO, perf): index FK columns for fast JOIN/CASCADE.
--   * function_search_path_mutable (WARN, security): pin search_path on the two
--     trigger functions and fully-qualify their object references.
-- Semantics of every policy are unchanged — only the auth.uid() call is wrapped.

-- ── 1. Index missing foreign-key columns ───────────────────────────────────
create index if not exists events_host_id_idx        on events (host_id)
create index if not exists messages_sender_id_idx     on messages (sender_id)
create index if not exists privacy_zones_user_id_idx  on privacy_zones (user_id)
create index if not exists reports_reporter_id_idx    on reports (reporter_id)
create index if not exists video_rooms_guest_id_idx   on video_rooms (guest_id)
create index if not exists video_rooms_host_id_idx    on video_rooms (host_id)
-- ── 2. Optimize RLS policies: auth.uid() -> (select auth.uid()) ─────────────
drop policy if exists blocks_self on blocks
create policy blocks_self on blocks for all to authenticated
  using ((select auth.uid()) = blocker_id)
  with check ((select auth.uid()) = blocker_id)
drop policy if exists members_self on community_members
create policy members_self on community_members for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists consent_log_own on consent_log
create policy consent_log_own on consent_log for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists conversations_read on conversations
create policy conversations_read on conversations for select to authenticated
  using (((select auth.uid()) = user_a) or ((select auth.uid()) = user_b))
drop policy if exists deletion_requests_own on deletion_requests
create policy deletion_requests_own on deletion_requests for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists rsvps_host_read on event_rsvps
create policy rsvps_host_read on event_rsvps for select to authenticated
  using (exists (select 1 from events e
                 where e.id = event_rsvps.event_id and e.host_id = (select auth.uid())))
drop policy if exists rsvps_self on event_rsvps
create policy rsvps_self on event_rsvps for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists events_write on events
create policy events_write on events for all to authenticated
  using ((select auth.uid()) = host_id)
  with check ((select auth.uid()) = host_id)
drop policy if exists likes_rw on likes
create policy likes_rw on likes for all to authenticated
  using ((select auth.uid()) = liker_id)
  with check ((select auth.uid()) = liker_id)
drop policy if exists prefs_self on match_preferences
create policy prefs_self on match_preferences for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists results_read_own on match_results
create policy results_read_own on match_results for select to authenticated
  using ((select auth.uid()) = user_id)
drop policy if exists matches_read on matches
create policy matches_read on matches for select to authenticated
  using (((select auth.uid()) = user_a) or ((select auth.uid()) = user_b))
drop policy if exists messages_read on messages
create policy messages_read on messages for select to authenticated
  using (exists (select 1 from conversations c
                 where c.id = messages.conversation_id
                   and (c.user_a = (select auth.uid()) or c.user_b = (select auth.uid()))))
drop policy if exists messages_send on messages
create policy messages_send on messages for insert to authenticated
  with check ((sender_id = (select auth.uid())) and exists (
                select 1 from conversations c
                where c.id = messages.conversation_id
                  and (c.user_a = (select auth.uid()) or c.user_b = (select auth.uid()))))
drop policy if exists zones_self on privacy_zones
create policy zones_self on privacy_zones for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists profiles_delete_own on profiles
create policy profiles_delete_own on profiles for delete to authenticated
  using ((select auth.uid()) = id)
drop policy if exists profiles_insert on profiles
create policy profiles_insert on profiles for insert to authenticated
  with check ((select auth.uid()) = id)
drop policy if exists profiles_write on profiles
create policy profiles_write on profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id)
drop policy if exists reports_insert on reports
create policy reports_insert on reports for insert to authenticated
  with check ((select auth.uid()) = reporter_id)
drop policy if exists reports_read_own on reports
create policy reports_read_own on reports for select to authenticated
  using ((select auth.uid()) = reporter_id)
drop policy if exists tokens_read_own on token_transactions
create policy tokens_read_own on token_transactions for select to authenticated
  using ((select auth.uid()) = user_id)
drop policy if exists travel_write on travel_plans
create policy travel_write on travel_plans for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id)
drop policy if exists video_participants on video_rooms
create policy video_participants on video_rooms for all to authenticated
  using (((select auth.uid()) = host_id) or ((select auth.uid()) = guest_id))
  with check (((select auth.uid()) = host_id) or ((select auth.uid()) = guest_id))
drop policy if exists vouches_write on vouches
create policy vouches_write on vouches for all to authenticated
  using ((select auth.uid()) = voucher_id)
  with check ((select auth.uid()) = voucher_id)
-- ── 3. Pin search_path on trigger functions (fully-qualified bodies) ────────
create or replace function public.create_match_on_mutual_like()
returns trigger language plpgsql
set search_path = ''
as $function$
declare a uuid; b uuid;
begin
    if exists (select 1 from public.likes l
               where l.liker_id = new.liked_id and l.liked_id = new.liker_id) then
        a := least(new.liker_id, new.liked_id);
        b := greatest(new.liker_id, new.liked_id);
        insert into public.matches (user_a, user_b) values (a, b)
        on conflict (user_a, user_b) do nothing;
    end if;
    return new;
end $function$
create or replace function public.sync_rep_on_vouch()
returns trigger language plpgsql
set search_path = ''
as $function$
declare new_count int; new_score int; new_tier text;
begin
    insert into public.reputation_scores (user_id, vouch_count, score)
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

    update public.reputation_scores set tier = new_tier where user_id = new.vouchee_id;
    update public.profiles set rep_score = new_score, vouches = new_count
        where id = new.vouchee_id;
    return new;
end $function$
