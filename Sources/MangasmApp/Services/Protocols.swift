import Foundation

// MARK: - AuthService
/// Handles authentication and account lifecycle (Phase 1 — Supabase Auth).
@MainActor
public protocol AuthService {
    func signInWithApple(consent: OnboardingConsent) async throws
    func signInWithGoogle(consent: OnboardingConsent) async throws
    func signInWithPhone(consent: OnboardingConsent) async throws
    /// Previews/tests when no Supabase config is present.
    func enterMock(consent: OnboardingConsent) async throws
    /// Permanently deletes the current account and all associated data (Guideline 5.1.1(v)).
    func deleteAccount() async throws
}

// MARK: - ProfileService
/// Reads and writes the current user's profile.
public protocol ProfileService {
    func current() -> Profile
    func update(_ profile: Profile)
}

// MARK: - MatchService
/// Provides featured candidate and nearby candidates; refresh cycles the featured slot.
public protocol MatchService {
    func featured() -> Candidate
    func nearby() -> [Candidate]
    func refresh()
}

// MARK: - ChatService
/// Provides conversations and messages; supports sending new messages.
public protocol ChatService {
    func conversations() -> [Conversation]
    func messages(for conversationID: String) -> [Message]
    func send(_ text: String, to conversationID: String)
    /// Find an existing conversation for a candidate, or create a new empty one.
    func conversation(for candidateID: String, name: String, avatarURL: String?) -> Conversation
}

// MARK: - EventService
/// Provides events and communities; supports RSVP.
public protocol EventService {
    func events() -> [EventItem]
    func communities() -> [Community]
    func rsvp(_ eventID: String)
}

// MARK: - ReputationService
/// Reputation scoring and photo-gating logic.
public protocol ReputationService {
    func score(for profileID: UUID) -> Int
    func canViewPhotos(viewerScore: Int, targetGate: Int) -> Bool
}

// MARK: - SafetyService
/// Block/report actions required by App Store Guideline 1.2 (UGC safety).
public protocol SafetyService {
    func block(_ userID: String)
    func unblock(_ userID: String)
    func isBlocked(_ userID: String) -> Bool
    func report(_ userID: String, reason: String)
}

// MARK: - ReportReason
/// Enumerated report categories. "underage" is especially critical for an 18+ app.
public enum ReportReason: String, CaseIterable, Sendable {
    case harassment
    case spam
    case fakeProfile
    case underage
    case other

    public var label: String {
        switch self {
        case .harassment:  return "Harassment"
        case .spam:        return "Spam"
        case .fakeProfile: return "Fake Profile"
        case .underage:    return "Underage (under 18)"
        case .other:       return "Other"
        }
    }
}
