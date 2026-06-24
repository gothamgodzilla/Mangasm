#!/usr/bin/env bash
# Rebuild missing local migration files from remote schema_migrations history.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

set -a
[ -f supabase/.env.local ] && . supabase/.env.local
set +a

: "${SUPABASE_ACCESS_TOKEN:?Set SUPABASE_ACCESS_TOKEN in supabase/.env.local}"
: "${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF in supabase/.env.local}"

API="https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}/database/query"

fetch_version() {
  local ver="$1"
  local out="/tmp/mig_${ver}.json"
  curl -sS -X POST "$API" \
    -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"query\":\"select version, name, statements from supabase_migrations.schema_migrations where version = '${ver}';\"}" \
    -o "$out"
  python3 - "$ver" "$out" <<'PY'
import json, sys, pathlib
ver, path = sys.argv[1], sys.argv[2]
rows = json.load(open(path))
if not rows:
    sys.exit(f"version {ver} not found on remote")
row = rows[0]
sql = "\n".join(row["statements"])
out = pathlib.Path("supabase/migrations") / f"{row['version']}_{row['name']}.sql"
out.write_text(sql + ("\n" if not sql.endswith("\n") else ""))
print(f"wrote {out} ({len(sql)} chars)")
PY
}

echo "── remote migration versions ──"
curl -sS -X POST "$API" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"query":"select version, name from supabase_migrations.schema_migrations order by version;"}'

echo ""
echo "── syncing any missing local files ──"
for ver in 0001 0002 0003 0004 0005; do
  file=(supabase/migrations/${ver}_*.sql)
  if [ ! -f "${file[0]}" ]; then
    echo "missing local ${ver}, fetching..."
    fetch_version "$ver"
  fi
done

echo "done"