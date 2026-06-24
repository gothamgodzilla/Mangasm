import SwiftUI

// MARK: - SignInView

/// Landmark slideshow + glass auth sheet. Apple uses Sign in with Apple when live auth is configured.
public struct SignInView: View {
    public let onAuthenticated: () -> Void

    public init(onAuthenticated: @escaping () -> Void) {
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            LandmarkSlides()
                .ignoresSafeArea()

            AuthSheet(onAuthenticated: onAuthenticated)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - AuthSheet

private struct AuthSheet: View {
    @EnvironmentObject private var env: AppEnvironment

    let onAuthenticated: () -> Void

    @State private var accepted = false
    @State private var nudge = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let cream = Color(red: 245/255, green: 235/255, blue: 214/255)

    private var consent: OnboardingConsent {
        OnboardingConsent(ageAffirmed: accepted, termsAccepted: accepted)
    }

    private var usesLiveAuth: Bool {
        env.auth is SupabaseAuthService
    }

    private func attemptMockEnter() {
        guard consent.mayEnter else {
            withAnimation(.easeInOut(duration: 0.2)) { nudge = true }
            return
        }
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                try await env.auth.enterMock(consent: consent)
                onAuthenticated()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func signIn(_ action: @escaping () async throws -> Void) {
        guard consent.mayEnter else {
            withAnimation(.easeInOut(duration: 0.2)) { nudge = true }
            return
        }
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                try await action()
                onAuthenticated()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 38, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 18)

            VStack(spacing: 0) {
                Text("Mangasm")
                    .font(MGFont.serif(38, .bold))
                    .tracking(38 * 0.01)
                    .foregroundStyle(MGGradient.goldHeading)
                    .shadow(color: MGColor.gold.opacity(0.4), radius: 7, x: 0, y: 1)

                Text("BY INVITATION · MEMBERS ONLY")
                    .font(MGFont.mono(8.5))
                    .tracking(8.5 * 0.28)
                    .foregroundStyle(cream.opacity(0.66))
                    .padding(.top, 7)
            }
            .padding(.bottom, 18)

            VStack(spacing: 9) {
                ProviderButton(kind: .apple) {
                    if usesLiveAuth {
                        signIn { try await env.auth.signInWithApple(consent: consent) }
                    } else {
                        attemptMockEnter()
                    }
                }
                ProviderButton(kind: .google) {
                    if usesLiveAuth {
                        signIn { try await env.auth.signInWithGoogle(consent: consent) }
                    } else {
                        attemptMockEnter()
                    }
                }
                ProviderButton(kind: .phone) {
                    if usesLiveAuth {
                        signIn { try await env.auth.signInWithPhone(consent: consent) }
                    } else {
                        attemptMockEnter()
                    }
                }
            }
            .disabled(isLoading)

            HStack(spacing: 10) {
                LinearGradient(colors: [.clear, MGColor.gold.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 1)
                Text("OR")
                    .font(MGFont.mono(8))
                    .tracking(8 * 0.2)
                    .foregroundStyle(cream.opacity(0.5))
                LinearGradient(colors: [MGColor.gold.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 1)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 4)

            Button(action: attemptMockEnter) {
                Text(isLoading ? "Signing in…" : "Enter the community →")
                    .font(MGFont.serif(16, .bold))
                    .tracking(16 * 0.04)
                    .foregroundStyle(MGColor.goldText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                colors: [MGColor.goldBright, MGColor.gold, MGColor.goldDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: MGColor.gold.opacity(0.7), radius: 16, x: 0, y: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.5), lineWidth: 0.7)
                            .allowsHitTesting(false)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            VStack(spacing: 7) {
                Button {
                    accepted.toggle()
                    if accepted { nudge = false }
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: accepted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(accepted ? MGColor.goldDeep
                                             : (nudge ? Color(red: 0.85, green: 0.3, blue: 0.3) : cream.opacity(0.6)))
                        Text("I confirm I'm 18+ and accept the Community Guidelines & Privacy Policy.")
                            .font(MGFont.mono(7.5))
                            .tracking(7.5 * 0.04)
                            .foregroundStyle(cream.opacity(0.72))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(7.5 * 0.7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("accept_toggle")

                if nudge {
                    Text("Please confirm to continue.")
                        .font(MGFont.mono(7.5))
                        .foregroundStyle(Color(red: 0.9, green: 0.4, blue: 0.4))
                        .accessibilityIdentifier("accept_nudge")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(MGFont.mono(7.5))
                        .foregroundStyle(Color(red: 0.9, green: 0.4, blue: 0.4))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 22)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .allowsHitTesting(false)
                )
                .shadow(color: .black.opacity(0.75), radius: 30, x: 0, y: -20)
        )
    }
}