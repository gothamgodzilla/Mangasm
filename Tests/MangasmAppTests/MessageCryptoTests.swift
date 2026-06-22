import XCTest
import CryptoKit
@testable import MangasmApp

/// Real E2E crypto core tests (Decision B). Pure/offline — no backend needed.
/// The only backend-gated part of E2E is public-key exchange (device_keys table).
final class MessageCryptoTests: XCTestCase {

    func testRoundTripDeliversPlaintext() throws {
        let bob = Curve25519.KeyAgreement.PrivateKey()
        let env = try MessageCrypto.seal("meet at the marina, 9pm", to: bob.publicKey)
        XCTAssertEqual(try MessageCrypto.openString(env, with: bob), "meet at the marina, 9pm")
    }

    func testWrongRecipientCannotDecrypt() throws {
        let bob = Curve25519.KeyAgreement.PrivateKey()
        let eve = Curve25519.KeyAgreement.PrivateKey()
        let env = try MessageCrypto.seal("private", to: bob.publicKey)
        XCTAssertThrowsError(try MessageCrypto.open(env, with: eve)) // eavesdropper fails
    }

    func testTamperedCiphertextFailsAuthentication() throws {
        let bob = Curve25519.KeyAgreement.PrivateKey()
        var env = try MessageCrypto.seal("integrity", to: bob.publicKey)
        var bytes = [UInt8](env.ciphertext)
        bytes[bytes.count - 1] ^= 0xFF                      // flip a tag bit
        env = MessageCrypto.Envelope(ephemeralPublicKey: env.ephemeralPublicKey,
                                     ciphertext: Data(bytes))
        XCTAssertThrowsError(try MessageCrypto.open(env, with: bob))
    }

    func testSamePlaintextProducesDifferentCiphertext() throws {
        let bob = Curve25519.KeyAgreement.PrivateKey()
        let a = try MessageCrypto.seal("dupe", to: bob.publicKey)
        let b = try MessageCrypto.seal("dupe", to: bob.publicKey)
        // Fresh ephemeral key per message => no ciphertext reuse.
        XCTAssertNotEqual(a.ciphertext, b.ciphertext)
        XCTAssertNotEqual(a.ephemeralPublicKey, b.ephemeralPublicKey)
    }

    func testServerSeesOnlyCiphertext() throws {
        // What the server would store must not contain the plaintext bytes.
        let bob = Curve25519.KeyAgreement.PrivateKey()
        let secret = "members-only location: pier 7, 9pm"
        let env = try MessageCrypto.seal(secret, to: bob.publicKey)
        XCTAssertFalse(env.ciphertext.range(of: Data(secret.utf8)) != nil,
                       "ciphertext must not contain the plaintext")
    }
}
