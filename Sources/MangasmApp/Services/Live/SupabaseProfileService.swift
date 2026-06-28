import Foundation
import Supabase

// MARK: - ProfileError
public enum ProfileError: LocalizedError, Sendable {
    case notAuthenticated
    case notFound
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Sign in to load your profile."
        case .notFound:         return "Profile not found."
        case .server(let msg):  return msg
        }
    }
}

// MARK: - SupabaseProfileService
@MainActor
public final class SupabaseProfileService: ProfileService {
    private let client: SupabaseClient
    private var profile: Profile
    private var visibility: Visibility

    public init(client: SupabaseClient, seed: Profile = .sample, visibility: Visibility = .sample) {
        self.client = client
        self.profile = seed
        self.visibility = visibility
    }

    public func current() -> Profile { profile }

    public func currentVisibility() -> Visibility { visibility }

    public func apply(profile: Profile, visibility: Visibility) {
        self.profile = profile
        self.visibility = visibility
    }

    public func loadFromServer() async throws {
        let userID = try await currentUserID()
        let row: ProfileRowMapper.Row = try await client
            .from("profiles")
            .select()
            .eq("id", value: userID.uuidString)
            .single()
            .execute()
            .value

        profile = ProfileRowMapper.profile(from: row)
        visibility = ProfileRowMapper.visibility(from: row)
    }

    public func saveToServer() async throws {
        let userID = try await currentUserID()
        let payload = ProfileRowMapper.updatePayload(profile: profile, visibility: visibility)

        try await client
            .from("profiles")
            .update(payload)
            .eq("id", value: userID.uuidString)
            .execute()
    }

    private func currentUserID() async throws -> UUID {
        do {
            return try await client.auth.session.user.id
        } catch {
            throw ProfileError.notAuthenticated
        }
    }
}