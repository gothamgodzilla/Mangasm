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
                ProviderButton(kind: .apple,  action: onEnter)
                ProviderButton(kind: .google, action: onEnter)
                ProviderButton(kind: .phone,  action: onEnter)
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
            Button(action: onEnter) {
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

            // Legal line — non-interactive per prototype (spans, not buttons)
            VStack(spacing: 0) {
                Text("18+ ONLY · VERIFIED PROFILES · BY CONTINUING YOU ACCEPT THE")
                    .font(MGFont.mono(7.5))
                    .tracking(7.5 * 0.04)
                    .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(7.5 * 0.7)

                HStack(spacing: 6) {
                    Text("COMMUNITY GUIDELINES")
                        .font(MGFont.mono(7.5))
                        .tracking(7.5 * 0.04)
                        .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.72))
                        .underline(true, color: Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.5))

                    Text("·")
                        .font(MGFont.mono(7.5))
                        .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.5))

                    Text("PRIVACY")
                        .font(MGFont.mono(7.5))
                        .tracking(7.5 * 0.04)
                        .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.72))
                        .underline(true, color: Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.5))
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
