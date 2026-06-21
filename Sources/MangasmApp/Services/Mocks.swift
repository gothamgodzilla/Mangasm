import Foundation

// MARK: - MockAuthService
public final class MockAuthService: AuthService {
    public init() {}
    public func enter() {
        // No-op: mock auth entry always succeeds
    }
}

// MARK: - MockProfileService
public final class MockProfileService: ProfileService {
    private var profile: Profile = .sample

    public init() {}

    public func current() -> Profile { profile }

    public func update(_ profile: Profile) {
        self.profile = profile
    }
}

// MARK: - MockMatchService
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
