import XCTest
@testable import MangasmApp

@MainActor
final class ServiceTests: XCTestCase {
    func testReputationGatesPhotosBelowThreshold() {
        let rep = MockReputationService()
        XCTAssertFalse(rep.canViewPhotos(viewerScore: 10, targetGate: 50))
        XCTAssertTrue(rep.canViewPhotos(viewerScore: 80, targetGate: 50))
    }
    func testMatchRefreshAdvancesFeatured() {
        let m = MockMatchService()
        let first = m.featured().id
        m.refresh()
        XCTAssertNotEqual(first, m.featured().id)
    }

    // MARK: - Safety service tests (App Store Guideline 1.2)
    func testSafetyBlockAndIsBlocked() {
        let safety = MockSafetyService()
        XCTAssertFalse(safety.isBlocked("user-42"))
        safety.block("user-42")
        XCTAssertTrue(safety.isBlocked("user-42"))
        safety.unblock("user-42")
        XCTAssertFalse(safety.isBlocked("user-42"))
    }

    func testSafetyBlockMultipleUsers() {
        let safety = MockSafetyService()
        safety.block("user-1")
        safety.block("user-2")
        XCTAssertTrue(safety.isBlocked("user-1"))
        XCTAssertTrue(safety.isBlocked("user-2"))
        XCTAssertFalse(safety.isBlocked("user-3"))
    }

    // MARK: - Auth deletion test (App Store Guideline 5.1.1(v))
    func testDeleteAccountIsNoop() async throws {
        // Verify deleteAccount() doesn't throw or crash in mock
        let auth = MockAuthService()
        try await auth.deleteAccount() // must complete without error
    }

    // MARK: - Block removes chat (Guideline 1.2 UX + dissolve proof)
    /// After removeConversation, both sides of the thread are gone:
    /// no conversation row, no received messages, no sent messages.
    func testRemoveConversationClearsReceivedAndSentMessages() {
        let chat = MockChatService()
        let seed = chat.conversations()
        XCTAssertFalse(seed.isEmpty, "mock should seed conversations")

        let target = seed[0]
        let candidateID = target.candidateID
        let beforeIDs = Set(chat.conversations().map(\.id))
        XCTAssertTrue(beforeIDs.contains(target.id))

        // Ensure there is message traffic on the thread (received + sent balance)
        let prior = chat.messages(for: target.id)
        XCTAssertFalse(prior.isEmpty, "seeded thread should have messages")
        let hadReceived = prior.contains { !$0.senderIsMe }
        let hadSent = prior.contains { $0.senderIsMe }
        // At least one direction exists in samples; after purge both must be empty
        _ = hadReceived
        _ = hadSent

        chat.removeConversation(for: candidateID)

        // Conversation list balanced: member gone
        XCTAssertFalse(
            chat.conversations().contains { $0.candidateID == candidateID },
            "blocked member conversation must be removed from list"
        )
        XCTAssertFalse(
            chat.conversations().contains { $0.id == target.id },
            "conversation id must not remain"
        )

        // Message store empty — dissolve destination state (deleted)
        let after = chat.messages(for: target.id)
        XCTAssertTrue(after.isEmpty, "all messages must be deleted after remove")
        XCTAssertFalse(after.contains { !$0.senderIsMe }, "received messages must be gone")
        XCTAssertFalse(after.contains { $0.senderIsMe }, "sent messages must be gone")
    }

    func testRemoveConversationIsIdempotent() {
        let chat = MockChatService()
        guard let target = chat.conversations().first else {
            return XCTFail("expected seed conversations")
        }
        chat.removeConversation(for: target.candidateID)
        chat.removeConversation(for: target.candidateID) // second call must not crash
        XCTAssertTrue(chat.messages(for: target.id).isEmpty)
        XCTAssertFalse(chat.conversations().contains { $0.candidateID == target.candidateID })
    }
}
