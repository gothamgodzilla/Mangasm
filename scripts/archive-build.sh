#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

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
  -allowProvisioningUpdates

echo "→ export App Store IPA"
rm -rf build/export
xcodebuild \
  -exportArchive \
  -archivePath build/Mangasm.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates

echo "✓ build/export/Mangasm.ipa ready"