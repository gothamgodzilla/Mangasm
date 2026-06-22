import Foundation

/// Pure 18+ age-gate logic (Phase 1 — auth/onboarding).
///
/// `now` is injected so the rule is deterministic and testable. The live
/// onboarding flow calls this before granting app access and logs the result
/// to `consent_log` server-side.
public enum AgeGate {
    public static let minimumAge = 18

    /// True iff `birthDate` is at least `minimumAge` years before `now`.
    /// A user whose 18th birthday is exactly `now` is an adult; one day short is not.
    public static func isAdult(
        birthDate: Date,
        now: Date,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> Bool {
        guard birthDate <= now else { return false }            // future DOB never adult
        let years = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        return years >= minimumAge
    }
}
