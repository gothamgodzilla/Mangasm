import Foundation
import CryptoKit

/// End-to-end message encryption core (Decision B — build real E2E).
///
/// ECIES over Curve25519: a fresh ephemeral key per message agrees a shared
/// secret with the recipient's long-term public key, HKDF derives a symmetric
/// key, and ChaChaPoly seals the body. Private keys live in the Secure
/// Enclave/Keychain on device and are NEVER uploaded — only public keys go to the
/// `device_keys` table (wired in the backend phase). The server stores only the
/// `Envelope` ciphertext, so it can never read message bodies.
///
/// This is the pure, offline-testable crypto core. Key storage, the device_keys
/// table, and the safety-number verification UI are layered on top later.
public enum MessageCrypto {

    public struct Envelope: Sendable, Equatable {
        /// Sender's ephemeral X25519 public key (raw 32 bytes).
        public let ephemeralPublicKey: Data
        /// ChaChaPoly combined output (nonce ‖ ciphertext ‖ tag).
        public let ciphertext: Data

        public init(ephemeralPublicKey: Data, ciphertext: Data) {
            self.ephemeralPublicKey = ephemeralPublicKey
            self.ciphertext = ciphertext
        }
    }

    private static let info = Data("mangasm-e2e-v1".utf8)

    private static func deriveKey(_ shared: SharedSecret) -> SymmetricKey {
        shared.hkdfDerivedSymmetricKey(
            using: SHA256.self, salt: Data(), sharedInfo: info, outputByteCount: 32
        )
    }

    /// Seal `plaintext` for the holder of `recipientPublicKey`.
    public static func seal(
        _ plaintext: Data,
        to recipientPublicKey: Curve25519.KeyAgreement.PublicKey
    ) throws -> Envelope {
        let ephemeral = Curve25519.KeyAgreement.PrivateKey()
        let shared = try ephemeral.sharedSecretFromKeyAgreement(with: recipientPublicKey)
        let sealed = try ChaChaPoly.seal(plaintext, using: deriveKey(shared))
        return Envelope(
            ephemeralPublicKey: ephemeral.publicKey.rawRepresentation,
            ciphertext: sealed.combined
        )
    }

    /// Open an `envelope` with the recipient's private key. Throws if the key is
    /// wrong or the ciphertext was tampered with (authentication failure).
    public static func open(
        _ envelope: Envelope,
        with recipientPrivateKey: Curve25519.KeyAgreement.PrivateKey
    ) throws -> Data {
        let ephemeralPub = try Curve25519.KeyAgreement.PublicKey(
            rawRepresentation: envelope.ephemeralPublicKey
        )
        let shared = try recipientPrivateKey.sharedSecretFromKeyAgreement(with: ephemeralPub)
        let box = try ChaChaPoly.SealedBox(combined: envelope.ciphertext)
        return try ChaChaPoly.open(box, using: deriveKey(shared))
    }

    // MARK: String convenience

    public static func seal(_ text: String, to pub: Curve25519.KeyAgreement.PublicKey) throws -> Envelope {
        try seal(Data(text.utf8), to: pub)
    }

    public static func openString(_ env: Envelope, with priv: Curve25519.KeyAgreement.PrivateKey) throws -> String {
        String(decoding: try open(env, with: priv), as: UTF8.self)
    }
}
