-- Mangasm — migration 0005: collapse overlapping permissive policies
-- Resolves advisor `multiple_permissive_policies` (perf) on events, event_rsvps,
-- travel_plans, vouches. Each had a SELECT `_read` policy AND a `FOR ALL` `_write`
-- policy; both apply to SELECT, so Postgres evaluates two permissive policies per
-- read. Fix: scope the write policies to INSERT/UPDATE/DELETE so a single policy
-- governs SELECT. Effective access is unchanged.

-- ── events: events_read is USING(true) (public read) → write policy need not cover SELECT
drop policy if exists events_write on events;
create policy events_write_ins on events for insert to authenticated
  with check ((select auth.uid()) = host_id);
create policy events_write_upd on events for update to authenticated
  using ((select auth.uid()) = host_id) with check ((select auth.uid()) = host_id);
create policy events_write_del on events for delete to authenticated
  using ((select auth.uid()) = host_id);
-- ── travel_plans: travel_read is USING(true) (public read)
drop policy if exists travel_write on travel_plans;
create policy travel_write_ins on travel_plans for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy travel_write_upd on travel_plans for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy travel_write_del on travel_plans for delete to authenticated
  using ((select auth.uid()) = user_id);
-- ── vouches: vouches_read is USING(true) (public read)
drop policy if exists vouches_write on vouches;
create policy vouches_write_ins on vouches for insert to authenticated
  with check ((select auth.uid()) = voucher_id);
create policy vouches_write_upd on vouches for update to authenticated
  using ((select auth.uid()) = voucher_id) with check ((select auth.uid()) = voucher_id);
create policy vouches_write_del on vouches for delete to authenticated
  using ((select auth.uid()) = voucher_id);
-- ── event_rsvps: owner (rsvps_self) + host (rsvps_host_read) both granted SELECT to
--    DIFFERENT users → merge both reads into one SELECT policy, write policy owner-only.
drop policy if exists rsvps_self on event_rsvps;
drop policy if exists rsvps_host_read on event_rsvps;
create policy rsvps_read on event_rsvps for select to authenticated
  using (
    (select auth.uid()) = user_id
    or exists (select 1 from events e
               where e.id = event_rsvps.event_id and e.host_id = (select auth.uid()))
  );
create policy rsvps_self_ins on event_rsvps for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy rsvps_self_upd on event_rsvps for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy rsvps_self_del on event_rsvps for delete to authenticated
  using ((select auth.uid()) = user_id);
