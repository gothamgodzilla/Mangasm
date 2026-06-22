import Foundation

/// Onboarding consent gate (Phase 1 — App Store Guideline 1.2 UGC safety + age
/// assurance). The user must affirm they are 18+ AND accept the Community
/// Guidelines / Privacy Policy before entering the app. When the live backend
/// lands, each affirmation is also written to `consent_log`
/// (kinds: `age_18plus`, `eula`) with `eulaVersion`.
public struct OnboardingConsent: Equatable, Sendable {
    public var ageAffirmed: Bool
    public var termsAccepted: Bool

    /// Bump when the EULA / community-guidelines text changes; stored with consent.
    public static let eulaVersion = "2026-06-22"

    public init(ageAffirmed: Bool = false, termsAccepted: Bool = false) {
        self.ageAffirmed = ageAffirmed
        self.termsAccepted = termsAccepted
    }

    /// Entry is allowed only when BOTH the 18+ affirmation and the terms
    /// acceptance are present.
    public var mayEnter: Bool { ageAffirmed && termsAccepted }
}
