import SwiftUI

// MARK: - SignInView

/// Landmark slideshow background + bottom glass auth sheet.
/// All auth controls call `onEnter()` — auth is stubbed this pass.
public struct SignInView: View {
    public let onEnter: () -> Void

    public init(onEnter: @escaping () -> Void) {
        self.onEnter = onEnter
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Full-screen landmark slides background
            LandmarkSlides()
                .ignoresSafeArea()

            // Bottom glass sheet
            AuthSheet(onEnter: onEnter)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - AuthSheet

private struct AuthSheet: View {
    let onEnter: () -> Void

    // Onboarding gate (Guideline 1.2 + 18+ assurance): entry is blocked until the
    // user affirms they are 18+ and accepts the Community Guidelines / Privacy.
    @State private var accepted = false
    @State private var nudge = false

    private let cream = Color(red: 245/255, green: 235/255, blue: 214/255)

    /// Provider / Enter taps route through here — only proceed when consent is given.
    private func attemptEnter() {
        if OnboardingConsent(ageAffirmed: accepted, termsAccepted: accepted).mayEnter {
            onEnter()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) { nudge = true }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 38, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 18)

            // Gold wordmark
            VStack(spacing: 0) {
                Text("Mangasm")
                    .font(MGFont.serif(38, .bold))
                    .tracking(38 * 0.01)
                    .foregroundStyle(MGGradient.goldHeading)
                    .shadow(color: MGColor.gold.opacity(0.4), radius: 7, x: 0, y: 1)

                Text("BY INVITATION · MEMBERS ONLY")
                    .font(MGFont.mono(8.5))
                    .tracking(8.5 * 0.28)
                    .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.66))
                    .padding(.top, 7)
            }
            .padding(.bottom, 18)

            // Provider buttons
            VStack(spacing: 9) {
                ProviderButton(kind: .apple,  action: attemptEnter)
                ProviderButton(kind: .google, action: attemptEnter)
                ProviderButton(kind: .phone,  action: attemptEnter)
            }

            // OR divider
            HStack(spacing: 10) {
                LinearGradient(
                    colors: [.clear, MGColor.gold.opacity(0.4)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(height: 1)

                Text("OR")
                    .font(MGFont.mono(8))
                    .tracking(8 * 0.2)
                    .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.5))

                LinearGradient(
                    colors: [MGColor.gold.opacity(0.4), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(height: 1)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 4)

            // "Enter the community" gold CTA button
            Button(action: attemptEnter) {
                Text("Enter the community →")
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

            // Consent gate — must be checked before entry (Guideline 1.2 + 18+).
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
                .accessibilityLabel("I am 18 or older and accept the Community Guidelines and Privacy Policy")
                .accessibilityAddTraits(accepted ? [.isSelected] : [])

                if nudge {
                    Text("Please confirm to continue.")
                        .font(MGFont.mono(7.5))
                        .tracking(7.5 * 0.04)
                        .foregroundStyle(Color(red: 0.9, green: 0.4, blue: 0.4))
                        .accessibilityIdentifier("accept_nudge")
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
