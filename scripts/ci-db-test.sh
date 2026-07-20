#!/usr/bin/env bash
# CI DB tests: apply the full migration chain (0001-0007) + auth shim to a
# Postgres reachable via libpq env vars (PGHOST/PGPORT/PGUSER/PGPASSWORD/PGDATABASE)
# and run the RLS/trigger assertions. Designed for a GitHub Actions `services:
# postgres` container — no Docker or Supabase CLI required.
set -euo pipefail
cd "$(dirname "$0")/.."

export PGHOST="${PGHOST:-127.0.0.1}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"
export PGDATABASE="${PGDATABASE:-postgres}"

psql_q() { psql -v ON_ERROR_STOP=1 -q "$@"; }

echo "== Reset schema =="
psql_q -c "drop schema if exists public cascade; create schema public; drop schema if exists auth cascade;"

echo "== Auth shim =="
psql_q -f supabase/tests/auth_shim.sql

echo "== Apply migrations =="
for m in supabase/migrations/[0-9]*.sql; do
  echo "  -> $m"
  psql_q -f "$m"
done

echo "== Grant authenticated role =="
psql_q -c "grant select,insert,update,delete on all tables in schema public to authenticated; grant usage on schema public to authenticated;"

echo "== RLS / trigger tests =="
psql_q -f supabase/tests/rls_tests.sql

echo "DB RLS/trigger tests: PASS"
