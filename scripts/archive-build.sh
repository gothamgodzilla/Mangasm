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
  -allowProvisioningUpdates "${AUTH[@]}"

echo "✓ build/export/Mangasm.ipa ready"