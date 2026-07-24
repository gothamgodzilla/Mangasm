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
    /// Active 2026-07-20: `dvomzrvslwdabwcwtvrg` (NEXT_PUBLIC / Mangasm client).
    /// Prior: `hcpzbxplnkyythzwkovy`; dead DNS: `zfwzrloxqqkkikedpruf`.
    public static let defaultURL = URL(string: "https://dvomzrvslwdabwcwtvrg.supabase.co")!

    /// Loads config from the app's Info.plist, falling back to the default URL.
    /// Returns nil if no publishable key is configured (so callers can stay on mocks).
    public static func fromInfoPlist(_ bundle: Bundle = .main) -> SupabaseConfig? {
        let info = bundle.infoDictionary
        let url = resolveURL(info?["SUPABASE_URL"] as? String)
        guard let key = info?["SUPABASE_PUBLISHABLE_KEY"] as? String,
              isUsablePublishableKey(key) else { return nil }
        return SupabaseConfig(url: url, publishableKey: key)
    }

    /// A plist URL value must be https with a real host to be trusted;
    /// anything else falls back to the known-good default. Guards against the
    /// xcconfig `//`-comment truncation that shipped "https:" in build 23.
    public static func resolveURL(_ raw: String?) -> URL {
        guard let raw,
              let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme == "https",
              let host = url.host, !host.isEmpty
        else { return defaultURL }
        return url
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
