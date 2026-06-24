import Foundation
import Supabase

/// Dependency injection container. Screens receive this as an EnvironmentObject.
/// Real implementations replace each mock when Supabase/Stripe are wired in.
@MainActor
public final class AppEnvironment: ObservableObject {
    public let auth: any AuthService
    public let profile: any ProfileService
    public let matches: any MatchService
    public let chat: any ChatService
    public let events: any EventService
    public let reputation: any ReputationService
    public let safety: any SafetyService

    public init(
        auth: any AuthService,
        profile: any ProfileService,
        matches: any MatchService,
        chat: any ChatService,
        events: any EventService,
        reputation: any ReputationService,
        safety: any SafetyService
    ) {
        self.auth = auth
        self.profile = profile
        self.matches = matches
        self.chat = chat
        self.events = events
        self.reputation = reputation
        self.safety = safety
    }

    /// Pre-built mock environment for previews, tests, and Simulator runs.
    public static let mock = AppEnvironment(
        auth: MockAuthService(),
        profile: MockProfileService(),
        matches: MockMatchService(),
        chat: MockChatService(),
        events: MockEventService(),
        reputation: MockReputationService(),
        safety: MockSafetyService()
    )

    /// Live auth when Supabase keys are configured; other services stay mock until Phase 2.
    public static func makeDefault() -> AppEnvironment {
        guard let config = SupabaseConfig.fromInfoPlist() else { return .mock }
        let client = SupabaseClient(supabaseURL: config.url, supabaseKey: config.publishableKey)
        return AppEnvironment(
            auth: SupabaseAuthService(client: client, projectURL: config.url),
            profile: MockProfileService(),
            matches: MockMatchService(),
            chat: MockChatService(),
            events: MockEventService(),
            reputation: MockReputationService(),
            safety: MockSafetyService()
        )
    }
}
