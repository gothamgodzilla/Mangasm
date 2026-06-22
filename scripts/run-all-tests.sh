#!/usr/bin/env bash
# Run every test suite Mangasm has, across all three runners.
#   1. SPM unit/logic tests (swift test)         — Phases 0,1,3,4 + E2E crypto
#   2. DB RLS/trigger tests (local Postgres)      — Phase 2
#   3. Xcode StoreKit + UI tests (simulator)      — Phases 3,5
set -uo pipefail
cd "$(dirname "$0")/.."
SIM="${SIM:-iPhone 17}"
fail=0

echo "==================== 1/3  swift test (SPM) ===================="
if swift test 2>&1 | tail -2; then :; else fail=1; fi

echo "==================== 2/3  DB RLS tests ======================="
if bash scripts/test-db.sh; then :; else fail=1; fi

echo "==================== 3/3  xcodebuild test (sim) =============="
xcodegen generate >/dev/null 2>&1 || true
if xcodebuild test -project MangasmiOS.xcodeproj -scheme Mangasm \
     -destination "platform=iOS Simulator,name=${SIM}" \
     -derivedDataPath .build/dd 2>&1 | grep -E "Executed [0-9]+ test|TEST (SUCCEEDED|FAILED)"; then :; else fail=1; fi

echo "=============================================================="
if [ "$fail" -eq 0 ]; then echo "ALL TEST SUITES GREEN"; else echo "SOME SUITE FAILED"; fi
exit "$fail"
