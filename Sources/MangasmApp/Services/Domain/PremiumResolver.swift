import Foundation

/// Resolves effective M+ premium status (Phase 3 — payments).
///
/// The SERVER (App Store Server Notifications -> `profiles.premium`) is
/// authoritative. The on-device StoreKit entitlement is only an optimistic hint
/// used until the server confirms. The verified audit found premium was
/// client-trusted; this enforces that once the server has spoken, a client-only
/// flag can never grant (or retain) premium.
public enum PremiumResolver {
    /// - Parameters:
    ///   - serverVerified: server-confirmed premium; `nil` = not yet known.
    ///   - localEntitlement: StoreKit `currentEntitlements` result on device.
    public static func isPremium(serverVerified: Bool?, localEntitlement: Bool) -> Bool {
        if let server = serverVerified { return server }   // authoritative
        return localEntitlement                            // optimistic fallback only while unknown
    }
}
