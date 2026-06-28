#!/usr/bin/env bash
# Push Apple IAP / App Store Server API secrets to Supabase Edge Functions.
# Run after you have Issuer ID + (optional) regenerated app-specific shared secret.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

set -a
[ -f supabase/.env.local ] && . supabase/.env.local
set +a

: "${SUPABASE_ACCESS_TOKEN:?Set SUPABASE_ACCESS_TOKEN in supabase/.env.local}"
: "${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF in supabase/.env.local}"

SUPABASE_GO="${SUPABASE_GO:-$HOME/.local/share/supabase/supabase-go}"
if [ ! -x "$SUPABASE_GO" ]; then
  echo "Install Supabase CLI first." >&2
  exit 1
fi

export SUPABASE_ACCESS_TOKEN

APPLE_BUNDLE_ID="${APPLE_BUNDLE_ID:-com.mangasm.app}"
APPLE_KEY_ID="${APPLE_KEY_ID:-5WWBWC52Q5}"
APPLE_ENVIRONMENT="${APPLE_ENVIRONMENT:-Sandbox}"
IAP_KEY_PATH="${IAP_KEY_PATH:-$HOME/.appstoreconnect/private_keys/SubscriptionKey_5WWBWC52Q5.p8}"

if [ -z "${APPLE_ISSUER_ID:-}" ]; then
  echo "Paste App Store Connect Issuer ID (Users and Access → Integrations → API):"
  read -r APPLE_ISSUER_ID
fi

if [ ! -f "$IAP_KEY_PATH" ]; then
  echo "Missing IAP key at $IAP_KEY_PATH" >&2
  exit 1
fi

# PEM on one line for supabase secrets (literal \n)
APPLE_PRIVATE_KEY="$(awk 'NF {sub(/\r/, ""); printf "%s\\n", $0}' "$IAP_KEY_PATH")"

ARGS=(
  --project-ref "$SUPABASE_PROJECT_REF"
  "APPLE_BUNDLE_ID=$APPLE_BUNDLE_ID"
  "APPLE_ISSUER_ID=$APPLE_ISSUER_ID"
  "APPLE_KEY_ID=$APPLE_KEY_ID"
  "APPLE_PRIVATE_KEY=$APPLE_PRIVATE_KEY"
  "APPLE_ENVIRONMENT=$APPLE_ENVIRONMENT"
)

if [ -n "${APPLE_SHARED_SECRET:-}" ]; then
  ARGS+=("APPLE_SHARED_SECRET=$APPLE_SHARED_SECRET")
  echo "→ Including APPLE_SHARED_SECRET (legacy receipts / server notifications)"
else
  echo "→ No APPLE_SHARED_SECRET set (StoreKit 2 JWS path uses IAP key + Issuer ID)"
fi

echo "→ Setting Supabase secrets on project $SUPABASE_PROJECT_REF"
"$SUPABASE_GO" secrets set "${ARGS[@]}"

echo "✓ Done. Redeploy if needed: ./scripts/deploy.sh"