import XCTest
@testable import MangasmApp

/// Guideline 1.2 regression tests — these FAIL if the content filter is
/// removed from the message-send or profile-save paths (blocker B1).
@MainActor
final class ContentFilterTests: XCTestCase {

    // MARK: - Filter core

    func testProfanityIsViolation() {
        XCTAssertNotNil(ContentFilter.firstViolation(in: "you stupid faggot"))
        XCTAssertNotNil(ContentFilter.firstViolation(in: "Fuck you"))
        XCTAssertNotNil(ContentFilter.firstViolation(in: "what a CUNT"))
    }

    func testLeetEvasionIsCaught() {
        XCTAssertNotNil(ContentFilter.firstViolation(in: "f4ggot"))
        XCTAssertNotNil(ContentFilter.firstViolation(in: "b!tch"))
        XCTAssertNotNil(ContentFilter.firstViolation(in: "$lut"))
    }

    func testHarassmentPhraseIsCaught() {
        XCTAssertNotNil(ContentFilter.firstViolation(in: "just kill yourself"))
        XCTAssertNotNil(ContentFilter.firstViolation(in: "kys loser"))
    }

    func testCleanTextPasses() {
        XCTAssertNil(ContentFilter.firstViolation(in: "Dinner at eight? I know a great rooftop spot."))
        XCTAssertNil(ContentFilter.firstViolation(in: "Cocktails and jazz, my treat 🍸"))
    }

    func testScunthorpeSubstringsPass() {
        // Denylisted terms inside longer innocent words must NOT match.
        XCTAssertNil(ContentFilter.firstViolation(in: "my class assignment on Scunthorpe"))
        XCTAssertNil(ContentFilter.firstViolation(in: "shiitake mushroom risotto"))
        XCTAssertNil(ContentFilter.firstViolation(in: "peacocking at the gala"))
    }

    // MARK: - Message send path (fails without the ChatInboxCache guard)

    func testObjectionableMessageIsRejectedBySendPath() {
        let cache = ChatInboxCache()
        let convo = cache.conversation(for: "peer-1", name: "Test", avatarURL: nil)

        XCTAssertNil(cache.send("fuck this", to: convo.id), "filtered message must not enter the inbox")
        XCTAssertTrue(cache.messages(for: convo.id).isEmpty, "no filtered message may be stored")
    }

    func testCleanMessageStillSends() {
        let cache = ChatInboxCache()
        let convo = cache.conversation(for: "peer-1", name: "Test", avatarURL: nil)

        XCTAssertNotNil(cache.send("See you at the mixer tonight", to: convo.id))
        XCTAssertEqual(cache.messages(for: convo.id).count, 1)
    }

    // MARK: - Profile save path

    func testProfileViolationDetectsAllFields() {
        XCTAssertNotNil(ContentFilter.profileViolation(name: "bitch", headline: "", bio: "", hobbies: []))
        XCTAssertNotNil(ContentFilter.profileViolation(name: "Opal", headline: "here to fuck", bio: "", hobbies: []))
        XCTAssertNotNil(ContentFilter.profileViolation(name: "Opal", headline: "", bio: "sliding in like a wh0re", hobbies: []))
        XCTAssertNotNil(ContentFilter.profileViolation(name: "Opal", headline: "", bio: "", hobbies: ["findom"]))
        XCTAssertNil(ContentFilter.profileViolation(
            name: "Opal",
            headline: "Rooftop bars & vintage cars",
            bio: "Sommelier, gym at dawn, opera on Sundays.",
            hobbies: ["wine", "opera"]
        ))
    }
}
