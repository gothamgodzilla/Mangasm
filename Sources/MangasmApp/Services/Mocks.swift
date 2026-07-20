import Foundation

// MARK: - MockAuthService
public final class MockAuthService: AuthService {
    /// Number of times deleteAccount() was invoked — lets tests assert the
    /// destructive action reached the service layer.
    public private(set) var deleteAccountCallCount = 0

    public init() {}

    public func signInWithApple(consent: OnboardingConsent) async throws {
        try await enterMock(consent: consent)
    }

    public func signInWithGoogle(consent: OnboardingConsent) async throws {
        try await enterMock(consent: consent)
    }

    public func signInWithPhone(consent: OnboardingConsent) async throws {
        try await enterMock(consent: consent)
    }

    public func enterMock(consent: OnboardingConsent) async throws {
        guard consent.mayEnter else { throw AuthError.consentRequired }
    }

    public func deleteAccount() async throws {
        deleteAccountCallCount += 1
    }
}

// MARK: - MockReferralService
@MainActor
public final class MockReferralService: ReferralService {
    public private(set) var lastRedeemedCode: String?

    public init() {}

    public func redeem(code: String) async throws -> ReferralRedeemResult {
        lastRedeemedCode = code
        return ReferralRedeemResult(ok: true, code: code.uppercased(), reward: nil)
    }
}

// MARK: - MockProfileService
@MainActor
public final class MockProfileService: ProfileService {
    private var profile: Profile = .sample
    private var visibility: Visibility = .sample

    public init() {}

    public func current() -> Profile { profile }

    public func currentVisibility() -> Visibility { visibility }

    public func apply(profile: Profile, visibility: Visibility) {
        self.profile = profile
        self.visibility = visibility
    }

    public func loadFromServer() async throws {}

    public func saveToServer() async throws {}
}

// MARK: - MockMatchService
@MainActor
public final class MockMatchService: MatchService {
    private let candidates: [Candidate] = Candidate.samples
    private var featuredIndex: Int = 0

    public init() {}

    public func featured() -> Candidate {
        candidates[featuredIndex % candidates.count]
    }

    public func nearby() -> [Candidate] {
        // All candidates except the featured one
        candidates.filter { $0.id != featured().id }
    }

    public func refresh() {
        featuredIndex = (featuredIndex + 1) % candidates.count
    }

    public func loadFromServer(viewerHobbies: [String]) async throws {
        _ = viewerHobbies
    }
}

// MARK: - MockChatService
public final class MockChatService: ChatService {
    private var convos: [Conversation] = Conversation.samples
    private var messagesByConversation: [String: [Message]]

    public init() {
        messagesByConversation = Dictionary(
            uniqueKeysWithValues: Conversation.samples.map { ($0.id, $0.messages) }
        )
    }

    public func conversations() -> [Conversation] { convos }

    public func messages(for conversationID: String) -> [Message] {
        messagesByConversation[conversationID] ?? []
    }

    public func removeConversation(for candidateID: String) {
        let removedIDs = Set(convos.filter { $0.candidateID == candidateID }.map(\.id))
        convos.removeAll { $0.candidateID == candidateID }
        removedIDs.forEach { messagesByConversation.removeValue(forKey: $0) }
    }

    public func send(_ text: String, to conversationID: String) {
        let msg = Message(
            id: UUID().uuidString,
            senderIsMe: true,
            text: text,
            timestamp: Date()
        )
        messagesByConversation[conversationID, default: []].append(msg)
        // Update the conversation's message list for preview
        if let idx = convos.firstIndex(where: { $0.id == conversationID }) {
            convos[idx].messages.append(msg)
        }
    }

    /// Returns the existing conversation matching the candidateID, or creates and stores a new one.
    @discardableResult
    public func conversation(for candidateID: String, name: String, avatarURL: String?) -> Conversation {
        if let existing = convos.first(where: { $0.candidateID == candidateID }) {
            return existing
        }
        let newConvo = Conversation(
            id: "conv-\(candidateID)",
            candidateID: candidateID,
            candidateName: name,
            candidateAvatarURL: avatarURL,
            messages: []
        )
        convos.append(newConvo)
        messagesByConversation[newConvo.id] = []
        return newConvo
    }
}

// MARK: - MockEventService
public final class MockEventService: EventService {
    private var eventList: [EventItem] = EventItem.samples
    private var rsvpedIDs: Set<String> = []

    public init() {}

    public func events() -> [EventItem] { eventList }

    public func communities() -> [Community] { Community.samples }

    public func rsvp(_ eventID: String) {
        guard !rsvpedIDs.contains(eventID) else { return }
        rsvpedIDs.insert(eventID)
        if let idx = eventList.firstIndex(where: { $0.id == eventID }) {
            eventList[idx].going += 1
        }
    }
}

// MARK: - MockReputationService
public final class MockReputationService: ReputationService {
    public init() {}

    public func score(for profileID: UUID) -> Int {
        // Returns the sample profile's score as a stand-in for any ID
        Profile.sample.repScore
    }

    public func canViewPhotos(viewerScore: Int, targetGate: Int) -> Bool {
        viewerScore >= targetGate
    }
}

// MARK: - MockSafetyService
public final class MockSafetyService: SafetyService {
    private var blockedIDs: Set<String> = []
    private var reportLog: [(userID: String, reason: String)] = []

    public init() {}

    public func block(_ userID: String) {
        blockedIDs.insert(userID)
        print("[MockSafetyService] blocked \(userID)")
    }

    public func unblock(_ userID: String) {
        blockedIDs.remove(userID)
        print("[MockSafetyService] unblocked \(userID)")
    }

    public func isBlocked(_ userID: String) -> Bool {
        blockedIDs.contains(userID)
    }

    public func report(_ userID: String, reason: String) {
        reportLog.append((userID: userID, reason: reason))
        print("[MockSafetyService] reported \(userID) for: \(reason)")
    }
}
