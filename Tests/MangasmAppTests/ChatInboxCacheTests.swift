import XCTest
@testable import MangasmApp

@MainActor
final class ChatInboxCacheTests: XCTestCase {

    // MARK: - Stable IDs

    func testStableConversationIDLowercasesUUID() {
        let raw = "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
        let id = ChatInboxCache.stableConversationID(candidateID: raw)
        XCTAssertEqual(id, "conv-\(raw.lowercased())")
    }

    // MARK: - Create / send / list

    func testConversationCreateAndReuse() {
        let cache = ChatInboxCache()
        let a = cache.conversation(for: "peer-1", name: "Alex", avatarURL: nil)
        let b = cache.conversation(for: "peer-1", name: "Alex", avatarURL: nil)
        XCTAssertEqual(a.id, b.id)
        XCTAssertEqual(cache.conversations().count, 1)
    }

    func testSendAppendsLocalMessageAndIgnoresBlank() {
        let cache = ChatInboxCache()
        let conv = cache.conversation(for: "peer-2", name: "Bo", avatarURL: nil)
        XCTAssertNil(cache.send("   ", to: conv.id), "whitespace-only must not send")
        let msg = cache.send("hello", to: conv.id)
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg?.text, "hello")
        XCTAssertTrue(msg?.senderIsMe == true)
        let stored = cache.messages(for: conv.id)
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(cache.conversations().first?.messages.count, 1)
    }

    // MARK: - Block → purge (Guideline 1.2)

    func testRemoveConversationClearsReceivedAndSent() {
        let peer = "blocked-peer"
        let convID = ChatInboxCache.stableConversationID(candidateID: peer)
        let seed = Conversation(
            id: convID,
            candidateID: peer,
            candidateName: "Blocked",
            messages: [
                Message(id: "r1", senderIsMe: false, text: "hey"),
                Message(id: "s1", senderIsMe: true, text: "hi"),
            ]
        )
        let cache = ChatInboxCache(conversations: [seed])
        XCTAssertEqual(cache.messages(for: convID).count, 2)

        cache.removeConversation(for: peer)

        XCTAssertTrue(cache.conversations().isEmpty)
        XCTAssertTrue(cache.messages(for: convID).isEmpty)
        XCTAssertFalse(cache.messages(for: convID).contains { !$0.senderIsMe })
        XCTAssertFalse(cache.messages(for: convID).contains { $0.senderIsMe })
    }

    func testRemoveConversationIsIdempotent() {
        let peer = "p"
        let seed = Conversation(
            id: ChatInboxCache.stableConversationID(candidateID: peer),
            candidateID: peer,
            candidateName: "X",
            messages: [Message(id: "1", senderIsMe: true, text: "yo")]
        )
        let cache = ChatInboxCache(conversations: [seed])
        cache.removeConversation(for: peer)
        cache.removeConversation(for: peer)
        XCTAssertTrue(cache.conversations().isEmpty)
    }

    func testBlockPolicyPlusPurgeHidesAndClearsThread() {
        // Compose the product rule: bidirectional hide + chat purge on block.
        var policy = BlockPolicy()
        let me = "me"
        let them = "them"
        let cache = ChatInboxCache()
        let conv = cache.conversation(for: them, name: "Them", avatarURL: nil)
        _ = cache.send("before block", to: conv.id)

        policy.block(them, by: me)
        cache.removeConversation(for: them)

        XCTAssertTrue(policy.isHidden(me, them))
        XCTAssertTrue(policy.isHidden(them, me))
        XCTAssertTrue(cache.conversations().isEmpty)
        XCTAssertTrue(cache.messages(for: conv.id).isEmpty)
        XCTAssertEqual(
            policy.visible(["a", them, "b"], viewer: me, id: { $0 }),
            ["a", "b"]
        )
    }

    func testReplaceHydrateOverwritesLocal() {
        let cache = ChatInboxCache()
        _ = cache.conversation(for: "old", name: "Old", avatarURL: nil)
        let peer = UUID().uuidString
        let convID = ChatInboxCache.stableConversationID(candidateID: peer)
        let remote = Conversation(
            id: convID,
            candidateID: peer,
            candidateName: "Remote",
            messages: [Message(id: "m", senderIsMe: false, text: "from server")]
        )
        cache.replace(
            conversations: [remote],
            messagesByConversation: [convID: remote.messages]
        )
        XCTAssertEqual(cache.conversations().count, 1)
        XCTAssertEqual(cache.conversations().first?.candidateName, "Remote")
        XCTAssertEqual(cache.messages(for: convID).first?.text, "from server")
    }
}
