import Foundation

// MARK: - CandidateRowMapper
enum CandidateRowMapper {
    struct DiscoverRow: Decodable, Sendable {
        let id: UUID
        let name: String
        let age: Int?
        let location: String?
        let headline: String?
        let bio: String?
        let hobbies: [String]?
        let position: String?
        let astro: String?
        let chinese: String?
        let life_path: Int?
        let avatar_url: String?
        let ai_match: Double?
    }

    struct MatchResultRow: Decodable, Sendable {
        let candidate_id: UUID
        let score: Double
        let astro_note: String?
        let num_note: String?
        let chinese_note: String?
    }

    static func candidate(
        from row: DiscoverRow,
        matchPct: Int? = nil,
        notes: CompatNotes? = nil,
        viewerHobbies: [String] = []
    ) -> Candidate {
        let hobbies = row.hobbies ?? []
        let shared = Set(viewerHobbies).intersection(hobbies).sorted()
        let pct = matchPct ?? Int((row.ai_match ?? 0).rounded())

        return Candidate(
            id: row.id.uuidString,
            name: row.name,
            age: row.age ?? 0,
            distanceLabel: distanceLabel(from: row.location),
            matchPct: min(100, max(0, pct)),
            astro: row.astro ?? "",
            chinese: row.chinese ?? "",
            lifePath: row.life_path ?? 0,
            position: row.position ?? "",
            sharedInterests: shared.isEmpty ? Array(hobbies.prefix(2)) : shared,
            hobbies: hobbies,
            bio: row.bio?.isEmpty == false ? row.bio! : (row.headline ?? ""),
            notes: notes ?? defaultNotes(astro: row.astro, lifePath: row.life_path, chinese: row.chinese),
            avatarURL: row.avatar_url
        )
    }

    static func notes(from result: MatchResultRow) -> CompatNotes {
        CompatNotes(
            astro: result.astro_note ?? "",
            numerology: result.num_note ?? "",
            chinese: result.chinese_note ?? ""
        )
    }

    private static func distanceLabel(from location: String?) -> String {
        guard let location, !location.isEmpty else { return "Nearby" }
        return location
    }

    private static func defaultNotes(astro: String?, lifePath: Int?, chinese: String?) -> CompatNotes {
        CompatNotes(
            astro: astro.map { "\($0) energy" } ?? "",
            numerology: lifePath.map { "Life path \($0)" } ?? "",
            chinese: chinese.map { "\($0) sign" } ?? ""
        )
    }
}