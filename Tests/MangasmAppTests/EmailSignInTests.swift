import XCTest
@testable import MangasmApp

/// Blocker B2 — email/password sign-in must exist on the AuthService seam
/// (phase1-auth spec §4a). Compile-time: the protocol requirement itself is
/// the regression guard; these tests cover the consent gate.
@MainActor
final class EmailSignInTests: XCTestCase {

    func testEmailSignInRequiresConsent() async {
        let auth = MockAuthService()
        let noConsent = OnboardingConsent(ageAffirmed: false, termsAccepted: false)

        do {
            try await auth.signInWithEmail(email: "review-demo@mangasm.app", password: "x", consent: noConsent)
            XCTFail("email sign-in must be gated on onboarding consent")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func testEmailSignInSucceedsWithConsent() async throws {
        let auth = MockAuthService()
        let consent = OnboardingConsent(ageAffirmed: true, termsAccepted: true)
        try await auth.signInWithEmail(email: "review-demo@mangasm.app", password: "x", consent: consent)
    }
}
