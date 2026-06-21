import Foundation

// MARK: - AuthService
/// Handles authentication entry (login/onboarding gate).
public protocol AuthService {
    func enter()
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
