import Foundation

/// Normalizes and parses cartoon referral codes (TWEETY, TAZ, …).
public enum ReferralCode: Sendable {
    private static let pattern = #"^[A-Z0-9]{2,24}$"#

    public static func normalize(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return nil }
        guard trimmed.range(of: pattern, options: .regularExpression) != nil else { return nil }
        return trimmed
    }

    public static func parse(from url: URL) -> String? {
        guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let raw = items.first(where: { $0.name.lowercased() == "code" })?.value else {
            return nil
        }
        return normalize(raw)
    }

    public static func promoURL(for code: String) -> URL? {
        guard let normalized = normalize(code) else { return nil }
        var components = URLComponents(string: "https://mangasm.app/promo")
        components?.queryItems = [URLQueryItem(name: "code", value: normalized)]
        return components?.url
    }
}