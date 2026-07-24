import Foundation

// MARK: - ContentFilter
/// Shared objectionable-content denylist applied to every UGC write path
/// (message send via ChatInboxCache, profile save via ProfileService).
/// Guideline 1.2 "filter objectionable content". Server-side enforcement
/// mirrors this list in migration 0008 (contains_objectionable trigger).
///
/// Matching is word-boundary based on a normalized form (lowercased, common
/// leet substitutions collapsed) so "Scunthorpe"-style substrings pass while
/// "f4ggot"-style evasions do not.
public enum ContentFilter {
    /// Slurs and harassment terms — never acceptable in any UGC field.
    /// Explicit sex-act terms are also rejected in v1 (clean-shell iOS surface,
    /// roadmap Decision A); revisit scope for profile bios post-launch.
    private static let denylist: Set<String> = [
        // slurs / hate
        "faggot", "fag", "nigger", "nigga", "kike", "spic", "chink", "tranny",
        "retard", "dyke",
        // harassment / violence
        "kys", "rape", "raping", "rapist",
        // explicit (clean-shell surface)
        "cock", "dick", "cum", "cumming", "blowjob", "handjob", "rimjob",
        "fuck", "fucking", "fucker", "motherfucker", "shit", "bitch", "cunt",
        "asshole", "pussy", "tits", "whore", "slut",
        // solicitation
        "escort4u", "paypig", "findom", "sellingcontent",
    ]

    /// Leet/character substitutions collapsed before matching.
    private static let substitutions: [Character: Character] = [
        "0": "o", "1": "i", "3": "e", "4": "a", "5": "s", "7": "t",
        "@": "a", "$": "s", "!": "i",
    ]

    /// Multi-word phrases matched against the squashed text (separators removed),
    /// so "kill yourself" and "k.i.l.l y.o.u.r.s.e.l.f" are both caught.
    private static let phraseDenylist: [String] = [
        "killyourself", "gokillyourself",
    ]

    /// The first denylisted term found in `text`, or nil if the text is clean.
    public static func firstViolation(in text: String) -> String? {
        for word in tokens(in: text) where denylist.contains(word) {
            return word
        }
        let squashed = tokens(in: text).joined()
        for phrase in phraseDenylist where squashed.contains(phrase) {
            return phrase
        }
        return nil
    }

    public static func isAcceptable(_ text: String) -> Bool {
        firstViolation(in: text) == nil
    }

    /// Checks every free-text field a member can publish on their profile.
    public static func profileViolation(name: String, headline: String, bio: String, hobbies: [String]) -> String? {
        for field in [name, headline, bio] + hobbies {
            if let hit = firstViolation(in: field) { return hit }
        }
        return nil
    }

    // MARK: - Private

    private static func tokens(in text: String) -> [String] {
        let normalized = String(text.lowercased().map { substitutions[$0] ?? $0 })
        return normalized
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
}
