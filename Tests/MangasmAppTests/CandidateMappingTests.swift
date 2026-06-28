import XCTest
@testable import MangasmApp

final class CandidateMappingTests: XCTestCase {
    func testDiscoverRowMapsToCandidate() {
        let row = CandidateRowMapper.DiscoverRow(
            id: UUID(uuidString: "B1B2B3B4-E5F6-7890-ABCD-EF1234567890")!,
            name: "Theo",
            age: 31,
            location: "1.2 km",
            headline: "Slow mornings",
            bio: "Mixologist with taste.",
            hobbies: ["Mixology", "Travel", "Sailing"],
            position: "Vers",
            astro: "Pisces",
            chinese: "Monkey",
            life_path: 3,
            avatar_url: "https://example.com/t.jpg",
            ai_match: 90.4
        )

        let candidate = CandidateRowMapper.candidate(
            from: row,
            viewerHobbies: ["Sailing", "House music"]
        )

        XCTAssertEqual(candidate.name, "Theo")
        XCTAssertEqual(candidate.matchPct, 90)
        XCTAssertTrue(candidate.sharedInterests.contains("Sailing"))
        XCTAssertEqual(candidate.distanceLabel, "1.2 km")
    }

    @MainActor
    func testMockMatchServiceLoadIsNoOp() async throws {
        let matches = MockMatchService()
        let before = matches.featured().id
        try await matches.loadFromServer(viewerHobbies: ["Sailing"])
        XCTAssertEqual(matches.featured().id, before)
    }
}