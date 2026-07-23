#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# App Store Connect API key — lets -allowProvisioningUpdates fetch/create profiles
# headlessly (no Apple ID signed into Xcode). Same defaults as scripts/go-upload.sh.
KEY_ID="${APP_STORE_CONNECT_API_KEY_KEY_ID:-${APPLE_KEY_ID:-982Y229Z6V}}"
ISSUER_ID="${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-${APPLE_ISSUER_ID:-a3b11ce5-b573-41a0-9c6b-24be2acbd6df}}"
KEY_PATH="${APP_STORE_CONNECT_API_KEY_KEY_FILEPATH:-${APPLE_AUTHKEY_P8_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8}}"
[[ -f "$KEY_PATH" ]] || KEY_PATH="$HOME/mastermind-ai/certs/AuthKey_${KEY_ID}.p8"
AUTH=( -authenticationKeyPath "$KEY_PATH" -authenticationKeyID "$KEY_ID" -authenticationKeyIssuerID "$ISSUER_ID" )

# Archive is the last step of a ship — never bake a half-committed tree into
# the IPA (build 21 got archived twice because edits interleaved with archiving).
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✗ working tree is dirty — commit (or stash) before archiving" >&2
  git status --short >&2
  exit 1
fi

echo "→ xcodegen"
xcodegen generate

echo "→ archive (Release, team 854XZ2543V)"
mkdir -p build
xcodebuild \
  -project MangasmiOS.xcodeproj \
  -scheme Mangasm \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/Mangasm.xcarchive \
  -derivedDataPath build/DerivedData \
  -quiet \
  archive \
  DEVELOPMENT_TEAM=854XZ2543V \
  -allowProvisioningUpdates "${AUTH[@]}"

echo "→ export App Store IPA"
rm -rf build/export
xcodebuild \
  -exportArchive \
  -archivePath build/Mangasm.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist \
  -quiet \
  -allowProvisioningUpdates "${AUTH[@]}"

# B3 acceptance gate: the archived app MUST carry a usable Supabase config.
# Without this, the Release fatalError guard crashes at launch (the build-22
# TestFlight incident) — or, before that guard existed, the app silently ran
# all-mock services in front of App Review.
APP_PLIST="build/Mangasm.xcarchive/Products/Applications/Mangasm.app/Info.plist"
EMBEDDED_KEY="$(plutil -extract SUPABASE_PUBLISHABLE_KEY raw "$APP_PLIST" 2>/dev/null || true)"
if [[ -z "$EMBEDDED_KEY" || "$EMBEDDED_KEY" == *'$('* || "${#EMBEDDED_KEY}" -lt 20 ]]; then
  echo "✗ SUPABASE_PUBLISHABLE_KEY missing/unresolved in archived Info.plist — this IPA would crash at launch (B3)." >&2
  exit 1
fi
echo "✓ Supabase config embedded (key length ${#EMBEDDED_KEY})"

echo "✓ build/export/Mangasm.ipa ready"