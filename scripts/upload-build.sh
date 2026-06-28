#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

IPA="${MANGASM_IPA:-$ROOT/build/export/Mangasm.ipa}"
if [[ ! -f "$IPA" ]]; then
  echo "Missing $IPA — run: ./scripts/archive-build.sh" >&2
  exit 1
fi

export APP_STORE_CONNECT_API_KEY_KEY_ID="${APP_STORE_CONNECT_API_KEY_KEY_ID:-9SCVWDNBJ8}"
export APP_STORE_CONNECT_API_KEY_KEY_FILEPATH="${APP_STORE_CONNECT_API_KEY_KEY_FILEPATH:-/Users/swagger/.appstoreconnect/private_keys/AuthKey_9SCVWDNBJ8.p8}"
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-a3b11ce5-b573-41a0-9c6b-24be2acbd6df}"

export MANGASM_IPA="$IPA"
fastlane upload_build