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
    func testDefaultWeatherIsRain() {
        let s = AppState()
        XCTAssertEqual(s.weather, .rain)
    }
    func testSelectedMatchDefaultsToNil() {
        let s = AppState()
        XCTAssertNil(s.selectedMatch)
    }
    func testDefaultProfileIsSample() {
        let s = AppState()
        XCTAssertEqual(s.profile.name, "Julian")
        XCTAssertEqual(s.profile.age, 32)
        XCTAssertEqual(s.profile.repScore, 42)
    }
    func testDefaultVisibilityMatchesSample() {
        let s = AppState()
        XCTAssertTrue(s.visibility.headline)
        XCTAssertFalse(s.visibility.into)   // fetishes hidden by default
    }
}
