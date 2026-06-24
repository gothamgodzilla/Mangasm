import Foundation

/// Connection config for the Supabase backend.
///
/// The project **URL** is public and may be embedded. The **publishable key**
/// is injected at build time (Info.plist key `SUPABASE_PUBLISHABLE_KEY`, fed from
/// an xcconfig / `supabase/.env.local`) so it is never committed to the repo.
/// Wire this into the Supabase Swift client when the live `AppEnvironment` lands
/// (see docs/backend-integration.md).
public struct SupabaseConfig: Sendable {
    public let url: URL
    public let publishableKey: String

    /// Dev project URL (public). Override via Info.plist `SUPABASE_URL`.
    public static let defaultURL = URL(string: "https://zfwzrloxqqkkikedpruf.supabase.co")!

    /// Loads config from the app's Info.plist, falling back to the dev URL.
    /// Returns nil if no publishable key is configured (so callers can stay on mocks).
    public static func fromInfoPlist(_ bundle: Bundle = .main) -> SupabaseConfig? {
        let info = bundle.infoDictionary
        let url = (info?["SUPABASE_URL"] as? String).flatMap(URL.init(string:)) ?? defaultURL
        guard let key = info?["SUPABASE_PUBLISHABLE_KEY"] as? String,
              !key.isEmpty, !key.contains("$(") else { return nil }   // unresolved build var → treat as absent
        return SupabaseConfig(url: url, publishableKey: key)
    }
}
