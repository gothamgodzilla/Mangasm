import XCTest
@testable import MangasmApp

/// Phase 1 — onboarding consent gate logic (18+ affirmation + terms acceptance).
final class OnboardingConsentTests: XCTestCase {

    func testNoConsentMeansNoEntry() {
        XCTAssertFalse(OnboardingConsent().mayEnter)
    }

    func testAgeAffirmationAloneIsNotEnough() {
        XCTAssertFalse(OnboardingConsent(ageAffirmed: true, termsAccepted: false).mayEnter)
    }

    func testTermsAcceptanceAloneIsNotEnough() {
        XCTAssertFalse(OnboardingConsent(ageAffirmed: false, termsAccepted: true).mayEnter)
    }

    func testBothAffirmationsAllowEntry() {
        XCTAssertTrue(OnboardingConsent(ageAffirmed: true, termsAccepted: true).mayEnter)
    }

    func testEulaVersionIsRecorded() {
        XCTAssertFalse(OnboardingConsent.eulaVersion.isEmpty,
                       "a versioned EULA must be recordable alongside consent")
    }
}
