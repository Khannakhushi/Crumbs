import SwiftUI

/// Animated brand mark for Crumbs.
/// One-shot intro: glass disc fades in, the "C" line draws itself, then three
/// crumbs pop in one-by-one with a bouncy spring (like 1...2...3).
/// After the intro, only a slow breathing halo remains.
struct CrumbsLogo: View {
    var size: CGFloat = 140
    /// When false, skip the intro and render in the final state.
    var isAnimating: Bool = true

    @State private var discIn = false
    @State private var lineProgress: CGFloat = 0
    @State private var dotIn: [Bool] = [false, false, false]
    @State private var dotAngle: [Double] = [-50, -50, -50]
    @State private var breathe = false
    @Environment(\.colorScheme) private var scheme

    private var glowColors: [Color] {
        scheme == .dark
            ? [Color(hex: "FF8A6C"), Color(hex: "F5A623")]
            : [Color(hex: "DE644B"), Color(hex: "F5A623")]
    }

    // Final positions: 3 beads on the SAME arc as the C line (radius 0.31),
    // spread well past the line's upper endpoint (which sits around -32°)
    // so all three are clearly inside the visible gap.
    private let dotTargetAngles: [Double] = [0, 25, 50]
    // Dots sit on an arc just outside the C line — visibly aligned with
    // the line's curve, but tucked into the gap between line and disc edge.
    private let dotRadius: CGFloat = 0.38

    // Born hidden behind the line at its upper-right endpoint, then slide
    // along the arc into the gap — beads being shed from the line tip.
    private let emissionAngle: Double = -50

    var body: some View {
        ZStack {
            // Outer halo (gentle breathe — only ambient motion that remains)
            Circle()
                .fill(LinearGradient(colors: glowColors,
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 1.9, height: size * 1.9)
                .opacity((scheme == .dark ? 0.32 : 0.22) * (discIn ? 1 : 0))
                .blur(radius: size * 0.5)
                .scaleEffect(breathe ? 1.06 : 0.96)

            // Inner halo
            Circle()
                .fill(LinearGradient(colors: glowColors,
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 1.25, height: size * 1.25)
                .opacity((scheme == .dark ? 0.45 : 0.35) * (discIn ? 1 : 0))
                .blur(radius: size * 0.22)
                .scaleEffect(breathe ? 1.04 : 0.97)

            // Glass disc
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(scheme == .dark ? 0.45 : 0.85),
                                         .white.opacity(scheme == .dark ? 0.05 : 0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .overlay(
                    // Subtle inner highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(scheme == .dark ? 0.18 : 0.5), .clear],
                                center: UnitPoint(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: size * 0.6
                            )
                        )
                        .blendMode(.plusLighter)
                )
                .shadow(color: glowColors[0].opacity((scheme == .dark ? 0.5 : 0.35) * (discIn ? 1 : 0)),
                        radius: size * 0.3, y: size * 0.08)
                .scaleEffect(discIn ? 1 : 0.5)
                .opacity(discIn ? 1 : 0)

            // Three beads — drawn BELOW the C line, all sitting on the
            // line's exact arc (same radius), spread into the gap. They
            // emerge from behind the line tip and slide along the curve.
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFE07A"), Color(hex: "F5A623")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.07, height: size * 0.07)
                    .shadow(color: Color(hex: "F5A623").opacity(0.7),
                            radius: size * 0.05)
                    .offset(x: size * dotRadius, y: 0)
                    .rotationEffect(.degrees(dotAngle[i]))
                    .scaleEffect(dotIn[i] ? 1 : 0)
                    .opacity(dotIn[i] ? 1 : 0)
            }

            // The "C" mark — draws itself in (drawn ON TOP of the dots so
            // they appear from behind it)
            CrescentMark(thickness: size * 0.08)
                .trim(from: 0, to: lineProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(hex: "FF8A6C"),
                            Color(hex: "F5A623"),
                            Color(hex: "FFC34D"),
                            Color(hex: "FF8A6C")
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .frame(width: size * 0.62, height: size * 0.62)
        }
        .onAppear { runIntro() }
    }

    private func runIntro() {
        guard isAnimating else {
            discIn = true
            lineProgress = 1
            dotIn = [true, true, true]
            dotAngle = dotTargetAngles
            // Static state: leave the breathe halo at rest, no animation.
            breathe = false
            return
        }

        // Reset (so re-appearing replays the intro).
        discIn = false
        lineProgress = 0
        dotIn = [false, false, false]
        dotAngle = [emissionAngle, emissionAngle, emissionAngle]
        breathe = false

        // 1. Disc + halo fade/scale in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
            discIn = true
        }

        // 2. Line draws itself
        withAnimation(.easeInOut(duration: 0.85).delay(0.25)) {
            lineProgress = 1
        }

        // 3. Three beads emerge from behind the C line's upper-right tip
        //    and slide along the disc's curve to their positions, 1...2...3.
        for i in 0..<3 {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.7)
                .delay(1.05 + Double(i) * 0.2)) {
                dotIn[i] = true
                dotAngle[i] = dotTargetAngles[i]
            }
        }

        // 4. Subtle ambient breathing kicks in after intro
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

/// An open crescent shape that reads as a "C".
private struct CrescentMark: Shape {
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        // Open arc — leaves a gap on the right, but the gap is tighter so the
        // line extends further toward 3 o'clock from both ends.
        path.addArc(center: center,
                    radius: radius,
                    startAngle: .degrees(-32),
                    endAngle: .degrees(212),
                    clockwise: true)
        return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
    }
}

// MARK: - Wordmark

/// "crumbs" text under the logo, with a soft glow.
struct CrumbsWordmark: View {
    var fontSize: CGFloat = 38
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text("crumbs")
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .tracking(-0.5)
            .foregroundStyle(
                LinearGradient(
                    colors: scheme == .dark
                        ? [Color(hex: "FFE4D2"), Color(hex: "FFB47A")]
                        : [Color(hex: "1A1715"), Color(hex: "5A4438")],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .shadow(color: Color(hex: "FF8A6C").opacity(scheme == .dark ? 0.4 : 0.0),
                    radius: 12, y: 4)
    }
}
