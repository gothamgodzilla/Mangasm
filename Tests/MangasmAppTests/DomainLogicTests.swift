import XCTest
import CryptoKit
@testable import MangasmApp

/// Unit tests for the pure domain logic of Phases 1, 3, and 4. These run without
/// any backend; the integration/UI tests for these phases remain gated on the
/// live dev Supabase project + Xcode simulator.
final class DomainLogicTests: XCTestCase {

    private let cal = Calendar(identifier: .gregorian)
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    // MARK: - Phase 1: AgeGate (critical path)

    func testExactly18TodayIsAdult() {
        let dob = date(2008, 6, 21)
        let now = date(2026, 6, 21)             // 18th birthday exactly
        XCTAssertTrue(AgeGate.isAdult(birthDate: dob, now: now))
    }

    func testOneDayShortOf18IsNotAdult() {
        let dob = date(2008, 6, 22)
        let now = date(2026, 6, 21)             // turns 18 tomorrow
        XCTAssertFalse(AgeGate.isAdult(birthDate: dob, now: now))
    }

    func testClearlyOver18IsAdult() {
        XCTAssertTrue(AgeGate.isAdult(birthDate: date(1990, 1, 1), now: date(2026, 6, 21)))
    }

    func testFutureBirthDateIsNotAdult() {
        XCTAssertFalse(AgeGate.isAdult(birthDate: date(2030, 1, 1), now: date(2026, 6, 21)))
    }

    // MARK: - Phase 1: SignInNonce (critical path)

    func testNonceHasRequestedLengthAndCharset() {
        let allowed = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        let n = SignInNonce.make(length: 40)
        XCTAssertEqual(n.count, 40)
        XCTAssertTrue(n.allSatisfy { allowed.contains($0) })
    }

    func testNoncesAreUnique() {
        XCTAssertNotEqual(SignInNonce.make(), SignInNonce.make())
    }

    func testSha256HexMatchesKnownVector() {
        // sha256("abc") well-known test vector
        XCTAssertEqual(
            SignInNonce.sha256Hex("abc"),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    func testSha256HexIsDeterministic() {
        let raw = SignInNonce.make()
        XCTAssertEqual(SignInNonce.sha256Hex(raw), SignInNonce.sha256Hex(raw))
    }

    // MARK: - Phase 4: BlockPolicy (bidirectional)

    func testBlockIsBidirectional() {
        var p = BlockPolicy()
        p.block("bob", by: "alice")
        XCTAssertTrue(p.isHidden("alice", "bob"))
        XCTAssertTrue(p.isHidden("bob", "alice"), "block must hide both directions")
    }

    func testUnblockRestoresVisibility() {
        var p = BlockPolicy()
        p.block("bob", by: "alice")
        p.unblock("bob", by: "alice")
        XCTAssertFalse(p.isHidden("alice", "bob"))
    }

    func testVisibleFiltersHiddenCandidates() {
        var p = BlockPolicy()
        p.block("x", by: "me")          // I blocked x
        p.block("me", by: "y")          // y blocked me
        let ids = ["x", "y", "z"]
        let visible = p.visible(ids, viewer: "me", id: { $0 })
        XCTAssertEqual(visible, ["z"], "both directions of a block must be filtered out")
    }

    // MARK: - Phase 3: PremiumResolver (server-authoritative, anti-fraud)

    func testServerTrueOverridesLocalFalse() {
        XCTAssertTrue(PremiumResolver.isPremium(serverVerified: true, localEntitlement: false))
    }

    func testServerFalseOverridesLocalTrue() {
        // The anti-fraud case: a spoofed client entitlement must not grant premium.
        XCTAssertFalse(PremiumResolver.isPremium(serverVerified: false, localEntitlement: true))
    }

    func testFallsBackToLocalWhenServerUnknown() {
        XCTAssertTrue(PremiumResolver.isPremium(serverVerified: nil, localEntitlement: true))
        XCTAssertFalse(PremiumResolver.isPremium(serverVerified: nil, localEntitlement: false))
    }
}
