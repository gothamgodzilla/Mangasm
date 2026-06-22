-- Local Supabase auth shim — emulates the parts of Supabase the migrations rely
-- on, so the schema + RLS can be tested against a plain Postgres container
-- (no Supabase CLI / remote project needed). NOT applied to real environments.

create extension if not exists pgcrypto;

create schema if not exists auth;

create table if not exists auth.users (
    id    uuid primary key default gen_random_uuid(),
    email text
);

-- auth.uid() reads the current request's JWT 'sub' claim, exactly like Supabase.
create or replace function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claims', true)::json ->> 'sub', '')::uuid;
$$;

do $$
begin
    if not exists (select from pg_roles where rolname = 'anon') then
        create role anon nologin; end if;
    if not exists (select from pg_roles where rolname = 'authenticated') then
        create role authenticated nologin; end if;
    if not exists (select from pg_roles where rolname = 'service_role') then
        create role service_role nologin bypassrls; end if;
end $$;

grant usage on schema public, auth to anon, authenticated, service_role;
