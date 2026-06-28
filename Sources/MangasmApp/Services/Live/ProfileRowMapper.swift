import Foundation

// MARK: - ProfileRowMapper
/// Maps between Swift `Profile` / `Visibility` and the `profiles` Postgres row.
enum ProfileRowMapper {
    struct Row: Decodable, Sendable {
        let id: UUID
        let name: String
        let age: Int?
        let location: String?
        let headline: String?
        let bio: String?
        let hobbies: [String]?
        let position: String?
        let into: [String]?
        let instagram: String?
        let x_handle: String?
        let astro: String?
        let chinese: String?
        let life_path: Int?
        let avatar_url: String?
        let photos: [String]?
        let vouches: Int?
        let rep_score: Int?
        let ai_match: Double?
        let premium: Bool?
        let referral_code: String?
        let referral_count: Int?
        let visibility: Visibility?
    }

    struct UpdatePayload: Encodable, Sendable {
        let name: String
        let age: Int?
        let location: String
        let headline: String
        let bio: String
        let hobbies: [String]
        let position: String
        let into: [String]
        let instagram: String
        let x_handle: String
        let astro: String
        let chinese: String
        let life_path: Int?
        let visibility: Visibility
    }

    static func profile(from row: Row) -> Profile {
        Profile(
            id: row.id,
            name: row.name,
            age: row.age ?? 0,
            location: row.location ?? "",
            headline: row.headline ?? "",
            bio: row.bio ?? "",
            hobbies: row.hobbies ?? [],
            position: row.position ?? "",
            into: row.into ?? [],
            instagram: row.instagram ?? "",
            x: row.x_handle ?? "",
            astro: row.astro ?? "",
            chinese: row.chinese ?? "",
            lifePath: row.life_path ?? 0,
            repScore: row.rep_score ?? 0,
            avatarURL: row.avatar_url,
            photos: row.photos ?? [],
            vouches: row.vouches ?? 0,
            aiMatch: row.ai_match ?? 0,
            premium: row.premium ?? false,
            referralCode: row.referral_code ?? "",
            referralCount: row.referral_count ?? 0
        )
    }

    static func visibility(from row: Row) -> Visibility {
        row.visibility ?? .sample
    }

    static func updatePayload(profile: Profile, visibility: Visibility) -> UpdatePayload {
        UpdatePayload(
            name: profile.name,
            age: profile.age > 0 ? profile.age : nil,
            location: profile.location,
            headline: profile.headline,
            bio: profile.bio,
            hobbies: profile.hobbies,
            position: profile.position,
            into: profile.into,
            instagram: profile.instagram,
            x_handle: profile.x,
            astro: profile.astro,
            chinese: profile.chinese,
            life_path: profile.lifePath > 0 ? profile.lifePath : nil,
            visibility: visibility
        )
    }
}