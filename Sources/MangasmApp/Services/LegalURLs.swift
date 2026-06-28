import Foundation

/// Public legal & support pages (App Store Connect + in-app links).
public enum LegalURLs {
    /// Apex redirects to www; both work in Safari / ASC.
    public static let siteBase = "https://www.mangasm.app"
    public static let privacy = "\(siteBase)/privacy.html"
    public static let terms = "\(siteBase)/terms.html"
    public static let moderation = "\(siteBase)/moderation.html"
    public static let support = "mailto:support@mangasm.app"
    public static let ai = "mailto:ai@mangasm.app"
    public static let promo = "\(siteBase)/promo"

    /// Display labels (mailto local-part is case-insensitive).
    public static let supportLabel = "support@mangasm.app"
    public static let aiLabel = "AI@Mangasm.app"
}