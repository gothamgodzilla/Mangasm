import Foundation
import Supabase

// MARK: - MatchError
public enum MatchError: LocalizedError, Sendable {
    case notAuthenticated

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Sign in to browse matches."
        }
    }
}

// MARK: - SupabaseMatchService
@MainActor
public final class SupabaseMatchService: MatchService {
    private let client: SupabaseClient
    private var candidates: [Candidate] = Candidate.samples
    private var featuredIndex = 0
    private var blockPolicy = BlockPolicy()
    private var viewerHobbies: [String] = Profile.sample.hobbies

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func featured() -> Candidate {
        guard !candidates.isEmpty else { return .sample }
        return candidates[featuredIndex % candidates.count]
    }

    public func nearby() -> [Candidate] {
        let featuredID = featured().id
        return candidates.filter { $0.id != featuredID }
    }

    public func refresh() {
        guard !candidates.isEmpty else { return }
        featuredIndex = (featuredIndex + 1) % candidates.count
    }

    public func loadFromServer(viewerHobbies: [String]) async throws {
        self.viewerHobbies = viewerHobbies
        let userID = try await currentUserID()
        await loadBlocks(viewerID: userID)

        let results: [CandidateRowMapper.MatchResultRow] = (try? await client
            .from("match_results")
            .select("candidate_id,score,astro_note,num_note,chinese_note")
            .eq("user_id", value: userID.uuidString)
            .order("score", ascending: false)
            .limit(20)
            .execute()
            .value) ?? []

        var mapped: [Candidate] = []

        if !results.isEmpty {
            let ids = results.map(\.candidate_id.uuidString)
            let rows: [CandidateRowMapper.DiscoverRow] = try await client
                .from("profiles")
                .select("id,name,age,location,headline,bio,hobbies,position,astro,chinese,life_path,avatar_url,ai_match")
                .in("id", values: ids)
                .execute()
                .value

            let rowByID = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
            for result in results {
                guard let row = rowByID[result.candidate_id] else { continue }
                let candidate = CandidateRowMapper.candidate(
                    from: row,
                    matchPct: Int(result.score.rounded()),
                    notes: CandidateRowMapper.notes(from: result),
                    viewerHobbies: viewerHobbies
                )
                mapped.append(candidate)
            }
        } else {
            let rows: [CandidateRowMapper.DiscoverRow] = try await client
                .from("profiles")
                .select("id,name,age,location,headline,bio,hobbies,position,astro,chinese,life_path,avatar_url,ai_match")
                .neq("id", value: userID.uuidString)
                .order("ai_match", ascending: false)
                .limit(20)
                .execute()
                .value

            mapped = rows.map {
                CandidateRowMapper.candidate(from: $0, viewerHobbies: viewerHobbies)
            }
        }

        mapped = blockPolicy.visible(mapped, viewer: userID.uuidString, id: \.id)

        if mapped.count < 3 {
            let existing = Set(mapped.map(\.id))
            let filler = Candidate.samples.filter { !existing.contains($0.id) }
            mapped.append(contentsOf: filler.prefix(3 - mapped.count))
        }

        candidates = mapped.isEmpty ? Candidate.samples : mapped
        featuredIndex = 0
    }

    private func loadBlocks(viewerID: UUID) async {
        struct BlockRow: Decodable { let blocked_id: UUID }

        guard let rows: [BlockRow] = try? await client
            .from("blocks")
            .select("blocked_id")
            .eq("blocker_id", value: viewerID.uuidString)
            .execute()
            .value else { return }

        var policy = BlockPolicy()
        let viewer = viewerID.uuidString
        for row in rows {
            policy.block(row.blocked_id.uuidString, by: viewer)
        }
        blockPolicy = policy
    }

    private func currentUserID() async throws -> UUID {
        do {
            return try await client.auth.session.user.id
        } catch {
            throw MatchError.notAuthenticated
        }
    }
}