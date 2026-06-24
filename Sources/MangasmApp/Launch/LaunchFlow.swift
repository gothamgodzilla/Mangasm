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
                SignInView(onAuthenticated: onEnter)
                    .opacity(crossFadeOpacity)
                    .transition(.opacity)
            }
        }
    }
}
