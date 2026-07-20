import XCTest

/// Accessibility — interactive controls must meet Apple's 44pt minimum touch target.
final class AccessibilityTests: XCTestCase {

    override func setUp() { continueAfterFailure = false }

    func testSettingsCloseButtonMeetsMinimumTouchTarget() {
        let app = XCUIApplication()
        app.launch()

        // Enter the app through the consent gate, then open Settings.
        let apple = app.buttons["Continue with Apple"]
        XCTAssertTrue(apple.waitForExistence(timeout: 30))
        app.buttons["accept_toggle"].tap()
        apple.tap()
        XCTAssertTrue(apple.waitForNonExistence(timeout: 8))
        app.buttons["settings_button"].tap()

        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 6), "Settings close button should exist")
        XCTAssertGreaterThanOrEqual(close.frame.height, 44, "close button must be ≥44pt tall (touch target)")
        XCTAssertGreaterThanOrEqual(close.frame.width, 44, "close button must be ≥44pt wide (touch target)")
    }
}
