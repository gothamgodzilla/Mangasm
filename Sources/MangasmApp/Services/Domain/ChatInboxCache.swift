import Foundation

// MARK: - ChatInboxCache
/// Pure in-memory DM inbox used by MockChatService samples and SupabaseChatService
/// local path. Network I/O stays outside so unit tests cover block→purge without
/// a live Supabase client.
@MainActor
public final class ChatInboxCache {
    private var convos: [Conversation]
    private var messagesByConversation: [String: [Message]]

    public init(
        conversations: [Conversation] = [],
        messagesByConversation: [String: [Message]] = [:]
    ) {
        self.convos = conversations
        if messagesByConversation.isEmpty, !conversations.isEmpty {
            self.messagesByConversation = Dictionary(
                uniqueKeysWithValues: conversations.map { ($0.id, $0.messages) }
            )
        } else {
            self.messagesByConversation = messagesByConversation
        }
    }

    public func conversations() -> [Conversation] { convos }

    public func messages(for conversationID: String) -> [Message] {
        messagesByConversation[conversationID] ?? []
    }

    /// Appends a local sent message. Returns the new message, or nil if text empty.
    @discardableResult
    public func send(_ text: String, to conversationID: String) -> Message? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let msg = Message(
            id: UUID().uuidString,
            senderIsMe: true,
            text: trimmed,
            timestamp: Date()
        )
        messagesByConversation[conversationID, default: []].append(msg)
        if let idx = convos.firstIndex(where: { $0.id == conversationID }) {
            convos[idx].messages.append(msg)
        }
        return msg
    }

    /// Removes every conversation + message store entry for a blocked candidate.
    public func removeConversation(for candidateID: String) {
        let removedIDs = Set(convos.filter { $0.candidateID == candidateID }.map(\.id))
        convos.removeAll { $0.candidateID == candidateID }
        removedIDs.forEach { messagesByConversation.removeValue(forKey: $0) }
    }

    @discardableResult
    public func conversation(
        for candidateID: String,
        name: String,
        avatarURL: String?,
        stableID: (String) -> String = { ChatInboxCache.stableConversationID(candidateID: $0) }
    ) -> Conversation {
        if let existing = convos.first(where: { $0.candidateID == candidateID }) {
            return existing
        }
        let id = stableID(candidateID)
        let newConvo = Conversation(
            id: id,
            candidateID: candidateID,
            candidateName: name,
            candidateAvatarURL: avatarURL,
            messages: []
        )
        convos.append(newConvo)
        messagesByConversation[id] = []
        return newConvo
    }

    /// Replace full inbox (e.g. after server hydrate).
    public func replace(
        conversations: [Conversation],
        messagesByConversation: [String: [Message]]
    ) {
        self.convos = conversations
        self.messagesByConversation = messagesByConversation
    }

    /// Stable conversation id for a peer (`conv-<uuid-lowercase>`).
    public static func stableConversationID(candidateID: String) -> String {
        "conv-\(candidateID.lowercased())"
    }
}
