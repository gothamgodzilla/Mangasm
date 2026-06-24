import XCTest
@testable import MangasmApp

@MainActor
final class ServiceTests: XCTestCase {
    func testReputationGatesPhotosBelowThreshold() {
        let rep = MockReputationService()
        XCTAssertFalse(rep.canViewPhotos(viewerScore: 10, targetGate: 50))
        XCTAssertTrue(rep.canViewPhotos(viewerScore: 80, targetGate: 50))
    }
    func testMatchRefreshAdvancesFeatured() {
        let m = MockMatchService()
        let first = m.featured().id
        m.refresh()
        XCTAssertNotEqual(first, m.featured().id)
    }

    // MARK: - Safety service tests (App Store Guideline 1.2)
    func testSafetyBlockAndIsBlocked() {
        let safety = MockSafetyService()
        XCTAssertFalse(safety.isBlocked("user-42"))
        safety.block("user-42")
        XCTAssertTrue(safety.isBlocked("user-42"))
        safety.unblock("user-42")
        XCTAssertFalse(safety.isBlocked("user-42"))
    }

    func testSafetyBlockMultipleUsers() {
        let safety = MockSafetyService()
        safety.block("user-1")
        safety.block("user-2")
        XCTAssertTrue(safety.isBlocked("user-1"))
        XCTAssertTrue(safety.isBlocked("user-2"))
        XCTAssertFalse(safety.isBlocked("user-3"))
    }

    // MARK: - Auth deletion test (App Store Guideline 5.1.1(v))
    func testDeleteAccountIsNoop() async throws {
        // Verify deleteAccount() doesn't throw or crash in mock
        let auth = MockAuthService()
        try await auth.deleteAccount() // must complete without error
    }
}
