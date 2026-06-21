import XCTest
@testable import MangasmApp

@MainActor
final class AppStateTests: XCTestCase {
    func testStartsInLaunchPhase() {
        let s = AppState()
        XCTAssertEqual(s.phase, .launch)
    }
    func testDefaultTabIsProfile() {
        let s = AppState()
        XCTAssertEqual(s.tab, .profile)
    }
    func testAllTabsHaveStableRawValues() {
        XCTAssertEqual(AppTab.allCases.count, 5)
    }
}
