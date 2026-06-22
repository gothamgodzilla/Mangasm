#!/usr/bin/env bash
# Phase 2 DB tests: apply migrations 0001-0003 + auth shim to a local Postgres
# (Docker) and run RLS/trigger assertions. No Supabase CLI / remote project needed.
set -euo pipefail
cd "$(dirname "$0")/.."

CONTAINER=mg-pg
IMAGE=postgres:16-alpine

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start it with: colima start" >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  docker run -d --name "$CONTAINER" -e POSTGRES_PASSWORD=postgres -p 54399:5432 "$IMAGE" >/dev/null
  for _ in $(seq 1 30); do
    docker exec "$CONTAINER" pg_isready -U postgres >/dev/null 2>&1 && break
    sleep 1
  done
fi

run() { docker exec -i "$CONTAINER" psql -U postgres -v ON_ERROR_STOP=1 -q; }

docker exec "$CONTAINER" psql -U postgres -q \
  -c "drop schema if exists public cascade; create schema public; drop schema if exists auth cascade;" >/dev/null

run < supabase/tests/auth_shim.sql >/dev/null
for m in supabase/migrations/0001_*.sql supabase/migrations/0002_*.sql supabase/migrations/0003_*.sql; do
  run < "$m" >/dev/null
done
docker exec "$CONTAINER" psql -U postgres -q \
  -c "grant select,insert,update,delete on all tables in schema public to authenticated; grant usage on schema public to authenticated;" >/dev/null

run < supabase/tests/rls_tests.sql
echo "DB RLS/trigger tests: PASS"
