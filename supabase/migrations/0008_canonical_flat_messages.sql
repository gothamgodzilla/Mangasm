-- ============================================================================
-- 0008 — Canonical flat messages schema + server-side content filter (B1/B5)
--
-- Decision Q1 (SPEC_INDEX.md): the flat sender_id/recipient_id shape is
-- canonical. The client (SupabaseChatService), the purge RPC (0007), and the
-- delete-account edge function all already assume it; only 0001/0004's
-- conversation_id shape disagrees. This migration reconciles deliberately.
--
-- SAFETY: if a conversation_id-shaped messages table exists AND holds rows,
-- this migration ABORTS — that state needs a hand-written data migration
-- (mangasm-backend lineage hazard). It only drops the old shape when empty.
-- ============================================================================

do $$
begin
  if exists (
    select from information_schema.columns
    where table_schema = 'public'
      and table_name = 'messages'
      and column_name = 'conversation_id'
  ) then
    if exists (select from public.messages limit 1) then
      raise exception
        '0008 aborted: messages has the conversation_id shape AND data. Write a data migration before reconciling.';
    end if;
    drop table public.messages cascade;
  end if;
end $$;

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users (id) on delete cascade,
  recipient_id uuid not null references auth.users (id) on delete cascade,
  body text not null check (length(body) between 1 and 4000),
  created_at timestamptz not null default now(),
  check (sender_id <> recipient_id)
);

create index if not exists messages_sender_created_idx
  on public.messages (sender_id, created_at);
create index if not exists messages_recipient_created_idx
  on public.messages (recipient_id, created_at);

alter table public.messages enable row level security;

-- Participants read their own threads.
drop policy if exists messages_read on public.messages;
create policy messages_read on public.messages
  for select to authenticated
  using (auth.uid() in (sender_id, recipient_id));

-- Sender must be self, and neither side may have blocked the other (M1).
drop policy if exists messages_send on public.messages;
create policy messages_send on public.messages
  for insert to authenticated
  with check (
    sender_id = auth.uid()
    and not exists (
      select from public.blocks b
      where (b.blocker_id = recipient_id and b.blocked_id = sender_id)
         or (b.blocker_id = sender_id and b.blocked_id = recipient_id)
    )
  );

-- Senders may delete their own rows (received rows purge via 0007's RPC).
drop policy if exists messages_delete on public.messages;
create policy messages_delete on public.messages
  for delete to authenticated
  using (sender_id = auth.uid());

-- ============================================================================
-- Server-side objectionable-content enforcement (B1). Mirrors the client's
-- ContentFilter denylist (Sources/MangasmApp/Services/Domain/ContentFilter.swift)
-- — keep the two lists in sync.
-- ============================================================================

create or replace function public.contains_objectionable(t text)
returns boolean
language sql
immutable
as $$
  select translate(lower(coalesce(t, '')), '013457@$!', 'oieastasi')
    ~ '\m(faggot|fag|nigger|nigga|kike|spic|chink|tranny|retard|dyke|kys|rape|raping|rapist|cock|dick|cum|cumming|blowjob|handjob|rimjob|fuck|fucking|fucker|motherfucker|shit|bitch|cunt|asshole|pussy|tits|whore|slut|findom|paypig)\M'
$$;

create or replace function public.reject_objectionable_message()
returns trigger
language plpgsql
as $$
begin
  if public.contains_objectionable(new.body) then
    raise exception 'message rejected: violates community guidelines'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists messages_content_filter on public.messages;
create trigger messages_content_filter
  before insert or update of body on public.messages
  for each row execute function public.reject_objectionable_message();

create or replace function public.reject_objectionable_profile()
returns trigger
language plpgsql
as $$
begin
  if public.contains_objectionable(new.name)
     or public.contains_objectionable(new.headline)
     or public.contains_objectionable(new.bio) then
    raise exception 'profile rejected: violates community guidelines'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_content_filter on public.profiles;
create trigger profiles_content_filter
  before insert or update of name, headline, bio on public.profiles
  for each row execute function public.reject_objectionable_profile();
