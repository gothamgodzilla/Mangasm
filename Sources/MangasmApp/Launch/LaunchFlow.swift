import SwiftUI

/// Orchestrates the launch sequence: Splash → Sign-In.
/// Provides `onEnter` callback for when the user has authenticated (or tapped through the stub).
public struct LaunchFlow: View {
    public let onEnter: () -> Void
    public init(onEnter: @escaping () -> Void) { self.onEnter = onEnter }

    enum Stage { case splash, signIn }
    @State private var stage: Stage = .splash
    @State private var crossFadeOpacity: Double = 1.0

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch stage {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.35)) { crossFadeOpacity = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        stage = .signIn
                        withAnimation(.easeIn(duration: 0.35)) { crossFadeOpacity = 1 }
                    }
                }
                .opacity(crossFadeOpacity)
                .transition(.opacity)
            case .signIn:
                // TODO(Task 9): replace stub with SignInView
                SignInStub(onEnter: onEnter)
                    .opacity(crossFadeOpacity)
                    .transition(.opacity)
            }
        }
    }
}

/// Temporary stub — Task 9 replaces this with the real SignInView.
private struct SignInStub: View {
    let onEnter: () -> Void
    // Guard: prevents the 2s auto-advance and the button from both firing onEnter().
    @State private var entered = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Mangasm")
                    .font(MGFont.serif(48, .bold))
                    .foregroundStyle(MGColor.launchOrange)
                Text("BY INVITATION · MEMBERS ONLY")
                    .font(MGFont.mono(9))
                    .tracking(9 * 0.28)
                    .foregroundStyle(Color.white.opacity(0.6))
                Button {
                    enterOnce()
                } label: {
                    Text("Enter the community →")
                        .font(MGFont.serif(16, .bold))
                        .tracking(16 * 0.04)
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(MGGradient.launchCTA, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(32)
        }
        .onAppear {
            // Auto-advance after 2s so simulator walkthroughs don't stall.
            // TODO(Task 9): remove when real SignInView replaces this stub.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { enterOnce() }
        }
    }

    private func enterOnce() {
        guard !entered else { return }
        entered = true
        onEnter()
    }
}
