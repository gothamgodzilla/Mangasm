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

    /// Live project URL (public). Override via Info.plist `SUPABASE_URL`.
    /// Confirmed resolving 2026-07-20 (`auth/v1/health` → 401 without apikey).
    /// Prior default `zfwzrloxqqkkikedpruf` no longer resolves in DNS.
    public static let defaultURL = URL(string: "https://hcpzbxplnkyythzwkovy.supabase.co")!

    /// Loads config from the app's Info.plist, falling back to the default URL.
    /// Returns nil if no publishable key is configured (so callers can stay on mocks).
    public static func fromInfoPlist(_ bundle: Bundle = .main) -> SupabaseConfig? {
        let info = bundle.infoDictionary
        let url = (info?["SUPABASE_URL"] as? String).flatMap(URL.init(string:)) ?? defaultURL
        guard let key = info?["SUPABASE_PUBLISHABLE_KEY"] as? String,
              isUsablePublishableKey(key) else { return nil }
        return SupabaseConfig(url: url, publishableKey: key)
    }

    /// Reject empty, unresolved xcconfig vars, and explicit placeholders.
    public static func isUsablePublishableKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        if trimmed.contains("$(") { return false } // unresolved build setting
        let upper = trimmed.uppercased()
        if upper.contains("PLACEHOLDER") { return false }
        if upper.contains("YOUR_KEY") { return false }
        if upper.contains("PASTE") { return false }
        // Real Supabase keys are long JWT-ish or sb_publishable_…
        if trimmed.count < 20 { return false }
        return true
    }
}
