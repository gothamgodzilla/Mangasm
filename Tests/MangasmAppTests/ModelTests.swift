import XCTest
@testable import MangasmApp

final class ModelTests: XCTestCase {
    func testProfileSampleMatchesPrototypeDefaults() {
        let p = Profile.sample
        XCTAssertEqual(p.name, "Julian")
        XCTAssertEqual(p.age, 32)
        XCTAssertEqual(p.position, "Vers")
    }
    func testBioMaxIsPremiumAware() {
        XCTAssertEqual(Profile.bioMax(premium: false), 300)
        XCTAssertEqual(Profile.bioMax(premium: true), 600)
    }
    func testProfileSampleFullFields() {
        let p = Profile.sample
        XCTAssertEqual(p.location, "Dubai → London")
        XCTAssertEqual(p.headline, "Slow mornings, fast cars")
        XCTAssertEqual(p.hiv, "Negative · on PrEP")
        XCTAssertEqual(p.lastTested, "May 2026")
        XCTAssertEqual(p.instagram, "julianv")
        XCTAssertEqual(p.x, "julian_v")
        XCTAssertEqual(p.astro, "Scorpio")
        XCTAssertEqual(p.chinese, "Dragon")
        XCTAssertEqual(p.lifePath, 7)
    }
    func testRepTierCases() {
        XCTAssertNotNil(RepTier.rising)
        XCTAssertNotNil(RepTier.veteran)
        XCTAssertNotNil(RepTier.elite)
    }
    func testCandidateSamplesPopulated() {
        XCTAssertGreaterThanOrEqual(Candidate.samples.count, 4)
        let first = Candidate.samples[0]
        XCTAssertFalse(first.name.isEmpty)
        XCTAssertGreaterThan(first.matchPct, 0)
    }
    func testConversationSamplesPopulated() {
        XCTAssertGreaterThanOrEqual(Conversation.samples.count, 3)
    }
    func testEventSamplesPopulated() {
        XCTAssertGreaterThanOrEqual(EventItem.samples.count, 3)
    }
    func testCommunitySamplesPopulated() {
        XCTAssertGreaterThanOrEqual(Community.samples.count, 4)
    }
    func testVenueSamplesPopulated() {
        XCTAssertGreaterThanOrEqual(Venue.samples.count, 2)
    }
    func testVisibilitySampleMatchesPrototypeDefaults() {
        let v = Visibility.sample
        XCTAssertTrue(v.headline)
        XCTAssertTrue(v.hobbies)
        XCTAssertFalse(v.into)
    }
    func testCompatNotesFields() {
        let n = CompatNotes(astro: "Water trine", numerology: "Seeker meets free spirit", chinese: "Dragon × Rat")
        XCTAssertEqual(n.astro, "Water trine")
    }
    func testMessageSampleIsMine() {
        let m = Message(id: "1", senderIsMe: true, text: "Hello")
        XCTAssertTrue(m.senderIsMe)
    }
    func testIdentifiable() {
        let p = Profile.sample
        XCTAssertFalse(p.id.uuidString.isEmpty)
    }
}
