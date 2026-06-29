import Foundation
import Supabase

// MARK: - SafetyError
public enum SafetyError: LocalizedError, Sendable {
    case notAuthenticated
    case invalidUserID
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Sign in to manage safety settings."
        case .invalidUserID:  return "Invalid user reference."
        case .server(let msg): return msg
        }
    }
}

// MARK: - SupabaseSafetyService
@MainActor
public final class SupabaseSafetyService: SafetyService {
    private let client: SupabaseClient
    private var blockedIDs: Set<String> = []

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func block(_ userID: String) {
        blockedIDs.insert(userID)
        Task { await persistBlock(userID: userID) }
    }

    public func unblock(_ userID: String) {
        blockedIDs.remove(userID)
        Task { await persistUnblock(userID: userID) }
    }

    public func isBlocked(_ userID: String) -> Bool {
        blockedIDs.contains(userID)
    }

    public func report(_ userID: String, reason: String) {
        Task { await persistReport(userID: userID, reason: reason) }
    }

    /// Hydrate local block cache from `blocks` (call after sign-in).
    public func loadFromServer() async {
        guard let viewerID = try? await currentUserID() else { return }

        struct BlockRow: Decodable { let blocked_id: UUID }

        guard let rows: [BlockRow] = try? await client
            .from("blocks")
            .select("blocked_id")
            .eq("blocker_id", value: viewerID.uuidString)
            .execute()
            .value else { return }

        blockedIDs = Set(rows.map { $0.blocked_id.uuidString })
    }

    private func persistBlock(userID: String) async {
        guard let blockerID = try? await currentUserID(),
              let blockedID = UUID(uuidString: userID) else { return }

        struct BlockInsert: Encodable {
            let blocker_id: UUID
            let blocked_id: UUID
        }

        _ = try? await client
            .from("blocks")
            .insert(BlockInsert(blocker_id: blockerID, blocked_id: blockedID))
            .execute()
    }

    private func persistUnblock(userID: String) async {
        guard let blockerID = try? await currentUserID(),
              let blockedID = UUID(uuidString: userID) else { return }

        _ = try? await client
            .from("blocks")
            .delete()
            .eq("blocker_id", value: blockerID.uuidString)
            .eq("blocked_id", value: blockedID.uuidString)
            .execute()
    }

    private func persistReport(userID: String, reason: String) async {
        guard let reporterID = try? await currentUserID(),
              let targetID = UUID(uuidString: userID) else { return }

        struct ReportInsert: Encodable {
            let reporter_id: UUID
            let target_id: UUID
            let reason: String
            let details: String
        }

        _ = try? await client
            .from("reports")
            .insert(ReportInsert(
                reporter_id: reporterID,
                target_id: targetID,
                reason: SafetyReasonMapper.dbValue(from: reason),
                details: reason
            ))
            .execute()
    }

    private func currentUserID() async throws -> UUID {
        do {
            return try await client.auth.session.user.id
        } catch {
            throw SafetyError.notAuthenticated
        }
    }

}

// MARK: - SafetyReasonMapper
enum SafetyReasonMapper {
    static func dbValue(from labelOrRaw: String) -> String {
        if let match = ReportReason.allCases.first(where: { $0.label == labelOrRaw || $0.rawValue == labelOrRaw }) {
            switch match {
            case .harassment:  return "harassment"
            case .spam:        return "spam"
            case .fakeProfile: return "fake_profile"
            case .underage:    return "underage"
            case .other:       return "other"
            }
        }
        return "other"
    }
}