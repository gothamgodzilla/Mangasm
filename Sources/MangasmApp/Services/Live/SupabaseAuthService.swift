import Foundation
import Supabase

@MainActor
public final class SupabaseAuthService: AuthService {
    private let client: SupabaseClient
    private let projectURL: URL
    #if canImport(AuthenticationServices) && canImport(UIKit)
    private let apple = AppleSignInPresenter()
    #endif

    public init(client: SupabaseClient, projectURL: URL) {
        self.client = client
        self.projectURL = projectURL
    }

    public func signInWithApple(consent: OnboardingConsent) async throws {
        guard consent.mayEnter else { throw AuthError.consentRequired }
        #if canImport(AuthenticationServices) && canImport(UIKit)
        let (idToken, nonce) = try await apple.signIn()
        try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        try await upsertProfileFromAppleSession()
        try await logConsent(consent)
        #else
        throw AuthError.notImplemented("Sign in with Apple")
        #endif
    }

    public func signInWithGoogle(consent: OnboardingConsent) async throws {
        guard consent.mayEnter else { throw AuthError.consentRequired }
        throw AuthError.notImplemented("Google sign-in")
    }

    public func signInWithPhone(consent: OnboardingConsent) async throws {
        guard consent.mayEnter else { throw AuthError.consentRequired }
        throw AuthError.notImplemented("Phone sign-in")
    }

    public func enterMock(consent: OnboardingConsent) async throws {
        guard consent.mayEnter else { throw AuthError.consentRequired }
    }

    public func deleteAccount() async throws {
        let session = try await client.auth.session
        let token = session.accessToken

        let url = projectURL.appending(path: "functions/v1/delete-account")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.server("Account deletion failed")
        }

        try await client.auth.signOut()
    }

    private func upsertProfileFromAppleSession() async throws {
        let user = try await client.auth.session.user
        let meta = user.userMetadata
        let full = meta["full_name"]?.stringValue ?? ""
        let given = meta["given_name"]?.stringValue ?? ""
        let family = meta["family_name"]?.stringValue ?? ""
        let combined = [given, family].filter { !$0.isEmpty }.joined(separator: " ")
        let name = full.isEmpty ? combined : full

        // Apple only sends the name on the FIRST authorization; on later logins
        // these fields come back empty. Skip the write when we have no real name
        // so we never overwrite a returning user's name (the profile row already
        // exists — created by the handle_new_user trigger on signup).
        guard !name.isEmpty else { return }

        struct ProfileRow: Encodable {
            let id: UUID
            let name: String
        }

        try await client
            .from("profiles")
            .upsert(ProfileRow(id: user.id, name: name))
            .execute()
    }

    private func logConsent(_ consent: OnboardingConsent) async throws {
        let user = try await client.auth.session.user

        struct ConsentRow: Encodable {
            let user_id: UUID
            let kind: String
            let version: String
            let value: String
        }

        let rows = [
            ConsentRow(user_id: user.id, kind: "age_18plus", version: OnboardingConsent.eulaVersion, value: "affirmed"),
            ConsentRow(user_id: user.id, kind: "eula", version: OnboardingConsent.eulaVersion, value: "accepted"),
        ]

        try await client.from("consent_log").insert(rows).execute()
    }
}

private extension AnyJSON {
    var stringValue: String? {
        switch self {
        case .string(let s): return s
        default: return nil
        }
    }
}