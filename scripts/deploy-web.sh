#!/usr/bin/env bash
# Deploy static legal/marketing pages to mangasm.app (Vercel project: web)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp "$ROOT/web/"*.html "$ROOT/web/vercel.json" "$ROOT/web/middleware.js" "$TMP/"
cp -R "$ROOT/web/.well-known" "$TMP/"
cd "$TMP"
vercel link --project web --yes
vercel deploy --prod --yes
echo "✓ https://www.mangasm.app (privacy, terms, moderation)"