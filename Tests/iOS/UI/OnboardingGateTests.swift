import XCTest

/// Phase 1 (UI) — the 18+/terms consent gate must block app entry until accepted.
/// Runs on the simulator via xcodebuild test; drives the app through the
/// accessibility API (no live backend needed).
final class OnboardingGateTests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    func testEntryRequiresAgeAndTermsAcceptance() {
        let app = XCUIApplication()
        app.launch()

        // Reach the sign-in sheet (splash auto-advances ~8.6s).
        let apple = app.buttons["Continue with Apple"]
        XCTAssertTrue(apple.waitForExistence(timeout: 30),
                      "sign-in should appear after the splash")

        // 1. Tapping a provider WITHOUT accepting must prompt, not enter.
        apple.tap()
        XCTAssertTrue(app.staticTexts["accept_nudge"].waitForExistence(timeout: 3),
                      "tapping before consent must show the confirm prompt")
        XCTAssertTrue(apple.exists, "must remain on the sign-in screen before consent")

        // 2. Accept the 18+/terms gate, then entry dismisses the sign-in screen.
        app.buttons["accept_toggle"].tap()
        apple.tap()
        XCTAssertTrue(apple.waitForNonExistence(timeout: 8),
                      "after accepting, entering should dismiss the sign-in screen")
    }
}
