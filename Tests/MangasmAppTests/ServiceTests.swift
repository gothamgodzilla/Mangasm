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
}
