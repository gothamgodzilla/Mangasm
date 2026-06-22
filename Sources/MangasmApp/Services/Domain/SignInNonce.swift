import Foundation
import CryptoKit

/// Sign in with Apple nonce helper (Phase 1 — SIWA).
///
/// Flow: generate a raw nonce, send its SHA256 hash to Apple in the auth request,
/// then send the *raw* nonce to Supabase `signInWithIdToken`. This binds the
/// returned identity token to this device's request and blocks replay attacks.
public enum SignInNonce {
    private static let charset = Array(
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._"
    )

    /// Cryptographically-random nonce. `SystemRandomNumberGenerator` is a CSPRNG
    /// on Apple platforms.
    public static func make(length: Int = 32) -> String {
        precondition(length > 0, "nonce length must be positive")
        var rng = SystemRandomNumberGenerator()
        return String((0..<length).map { _ in charset[Int.random(in: 0..<charset.count, using: &rng)] })
    }

    /// Lowercase hex SHA256 — the form Apple expects for the hashed nonce.
    public static func sha256Hex(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
