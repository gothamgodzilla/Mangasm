#!/usr/bin/env bash
# One-shot upload: paste Issuer ID when prompted, or set APP_STORE_CONNECT_API_KEY_ISSUER_ID
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IPA="$ROOT/build/export/Mangasm.ipa"

if [[ ! -f "$IPA" ]]; then
  echo "Building IPA first…"
  "$ROOT/scripts/archive-build.sh"
fi

export APP_STORE_CONNECT_API_KEY_KEY_ID="${APP_STORE_CONNECT_API_KEY_KEY_ID:-9SCVWDNBJ8}"
export APP_STORE_CONNECT_API_KEY_KEY_FILEPATH="${APP_STORE_CONNECT_API_KEY_KEY_FILEPATH:-/Users/swagger/.appstoreconnect/private_keys/AuthKey_9SCVWDNBJ8.p8}"
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-a3b11ce5-b573-41a0-9c6b-24be2acbd6df}"

if [[ -z "${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-}" ]]; then
  echo "Paste App Store Connect Issuer ID (Users and Access → Integrations → API):"
  read -r APP_STORE_CONNECT_API_KEY_ISSUER_ID
  export APP_STORE_CONNECT_API_KEY_ISSUER_ID
fi

cd "$ROOT"
fastlane upload_build

echo ""
echo "✓ Upload started. Watch TestFlight → Builds for 1.0.0 (8)"