#!/usr/bin/env bash
# Apply Mangasm migrations to the dev project via the Supabase Management API.
# Works where the `supabase` CLI is sandbox-blocked but plain HTTPS is allowed.
#
# Requires a Supabase Personal Access Token (https://supabase.com/dashboard/account/tokens):
#   put it in supabase/.env.local (git-ignored) as:  SUPABASE_ACCESS_TOKEN=sbp_...
# Then:  bash supabase/apply-migrations.sh
set -euo pipefail
cd "$(dirname "$0")/.."

set -a; [ -f supabase/.env.local ] && . supabase/.env.local; set +a
: "${SUPABASE_ACCESS_TOKEN:?Set SUPABASE_ACCESS_TOKEN (sbp_...) in supabase/.env.local}"
REF="${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF in supabase/.env.local}"
API="https://api.supabase.com/v1/projects/${REF}/database/query"

run_sql() { # $1 = sql text
  curl -sS --max-time 60 -X POST "$API" \
    -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$(jq -Rs '{query: .}' <<<"$1")"
}

for f in supabase/migrations/0001_*.sql supabase/migrations/0002_*.sql; do
  echo "── applying $f ──"
  out=$(run_sql "$(cat "$f")")
  echo "$out" | head -c 400; echo
  echo "$out" | grep -qi '"message"' && { echo "ERROR applying $f"; exit 1; } || true
done

echo "── reloading PostgREST schema cache ──"
run_sql "notify pgrst, 'reload schema';" >/dev/null || true

echo "── verifying tables ──"
run_sql "select table_name from information_schema.tables where table_schema='public' order by table_name;"
