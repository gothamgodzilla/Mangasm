import XCTest
@testable import MangasmApp

final class ProfileMappingTests: XCTestCase {
    func testRowMapsToProfileAndVisibility() {
        let row = ProfileRowMapper.Row(
            id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
            name: "Alex",
            age: 28,
            location: "London",
            headline: "Slow mornings",
            bio: "Bio text",
            hobbies: ["Sailing", "Jazz"],
            position: "Vers",
            into: ["Roleplay"],
            instagram: "alexv",
            x_handle: "alex_v",
            astro: "Leo",
            chinese: "Dragon",
            life_path: 7,
            avatar_url: "https://example.com/a.jpg",
            photos: ["https://example.com/p1.jpg"],
            vouches: 42,
            rep_score: 55,
            ai_match: 91.5,
            premium: true,
            referral_code: "TAZ",
            referral_count: 3,
            visibility: Visibility(into: true, photos: false)
        )

        let profile = ProfileRowMapper.profile(from: row)
        XCTAssertEqual(profile.name, "Alex")
        XCTAssertEqual(profile.age, 28)
        XCTAssertEqual(profile.x, "alex_v")
        XCTAssertEqual(profile.lifePath, 7)
        XCTAssertEqual(profile.repScore, 55)
        XCTAssertEqual(profile.aiMatch, 91.5)
        XCTAssertTrue(profile.premium)
        XCTAssertEqual(profile.referralCode, "TAZ")
        XCTAssertEqual(profile.referralCount, 3)
        XCTAssertEqual(profile.photos.count, 1)

        let visibility = ProfileRowMapper.visibility(from: row)
        XCTAssertTrue(visibility.into)
        XCTAssertFalse(visibility.photos)
        XCTAssertTrue(visibility.headline)
    }

    func testUpdatePayloadOmitsZeroAgeAndLifePath() {
        var profile = Profile.sample
        profile.age = 0
        profile.lifePath = 0
        profile.name = "New Member"

        let payload = ProfileRowMapper.updatePayload(
            profile: profile,
            visibility: Visibility(into: false)
        )

        XCTAssertEqual(payload.name, "New Member")
        XCTAssertNil(payload.age)
        XCTAssertNil(payload.life_path)
        XCTAssertEqual(payload.x_handle, profile.x)
        XCTAssertFalse(payload.visibility.into)
    }

    @MainActor
    func testMockProfileServiceApplyAndNoOpSync() async throws {
        let service = MockProfileService()
        var profile = Profile.sample
        profile.name = "Changed"
        let visibility = Visibility(into: true)

        service.apply(profile: profile, visibility: visibility)
        XCTAssertEqual(service.current().name, "Changed")
        XCTAssertTrue(service.currentVisibility().into)

        try await service.loadFromServer()
        try await service.saveToServer()
    }
}