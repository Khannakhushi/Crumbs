import SwiftUI

/// Plays a short launch animation, then shows the app content.
struct LaunchView<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content

    @State private var phase: Phase = .start
    @State private var revealApp = false

    enum Phase {
        case start    // logo small, faded
        case bloom    // logo grows + glows
        case settle   // logo eases in place
        case done     // app fades in over the logo
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Backdrop — always dark, matches the dark-by-default app
            backdrop
                .opacity(revealApp ? 0 : 1)
                .animation(.easeInOut(duration: 0.7), value: revealApp)
                .ignoresSafeArea()

            // Logo + wordmark — positioned and sized identically to the
            // welcome step in OnboardingView, so the crossfade looks like
            // one continuous logo flowing into the next screen.
            VStack(spacing: 32) {
                Spacer()

                CrumbsLogo(size: 150, isAnimating: true)
                    .scaleEffect(scaleForPhase)
                    .opacity(opacityForPhase)
                    .blur(radius: blurForPhase)

                CrumbsWordmark(fontSize: 52)
                    .opacity(phase == .start ? 0 : (revealApp ? 0 : 1))
                    .offset(y: phase == .start ? 14 : 0)

                Spacer()
                Spacer()
            }
            .environment(\.colorScheme, .dark)
            .opacity(revealApp ? 0 : 1)
            .animation(.easeInOut(duration: 0.7), value: revealApp)

            // Real app, revealed at the end with a slow crossfade so the
            // logo transition feels continuous, not snappy.
            if revealApp {
                content
                    .transition(.opacity.animation(.easeInOut(duration: 0.7)))
            }
        }
        .onAppear { runSequence() }
    }

    private var backdrop: some View {
        ZStack {
            Color(hex: "0A0807")

            RadialGradient(
                colors: [
                    Color(hex: "FF8A6C").opacity(0.35),
                    .clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 420
            )
            .blur(radius: 40)
        }
    }

    private var scaleForPhase: CGFloat {
        switch phase {
        case .start: return 0.6
        case .bloom: return 1.06
        case .settle: return 1.0
        case .done: return 1.0
        }
    }

    private var opacityForPhase: Double {
        phase == .start ? 0 : 1
    }

    private var blurForPhase: CGFloat {
        switch phase {
        case .start: return 14
        case .bloom: return 0
        case .settle: return 0
        case .done: return 0
        }
    }

    private func runSequence() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            phase = .bloom
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                phase = .settle
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.6)) {
                revealApp = true
            }
        }
    }
}
