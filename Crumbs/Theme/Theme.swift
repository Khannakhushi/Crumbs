import SwiftUI

// MARK: - Theme

enum Theme {
    // Adaptive colors
    static let bg = Color(UIColor { t in
        t.dark ? UIColor(r: 14, g: 12, b: 10) : UIColor(r: 255, g: 250, b: 245)
    })

    static let cardBg = Color(UIColor { t in
        t.dark ? UIColor(r: 26, g: 23, b: 20) : .white
    })

    static let cardBgElevated = Color(UIColor { t in
        t.dark ? UIColor(r: 38, g: 34, b: 30) : UIColor(r: 247, g: 242, b: 236)
    })

    static let accent = Color(UIColor { t in
        t.dark ? UIColor(r: 255, g: 138, b: 108) : UIColor(r: 222, g: 100, b: 75)
    })

    static let accentSoft = Color(UIColor { t in
        t.dark ? UIColor(r: 255, g: 138, b: 108, a: 0.12) : UIColor(r: 222, g: 100, b: 75, a: 0.1)
    })

    static let gold = Color(UIColor { t in
        t.dark ? UIColor(r: 255, g: 195, b: 77) : UIColor(r: 235, g: 160, b: 40)
    })

    static let textPrimary = Color(UIColor { t in
        t.dark ? UIColor(r: 248, g: 243, b: 238) : UIColor(r: 22, g: 20, b: 18)
    })

    static let textSecondary = Color(UIColor { t in
        t.dark ? UIColor(r: 130, g: 122, b: 114) : UIColor(r: 118, g: 112, b: 105)
    })

    static let divider = Color(UIColor { t in
        t.dark ? UIColor(r: 44, g: 39, b: 34) : UIColor(r: 232, g: 225, b: 217)
    })

    static let heartFill = Color(UIColor { t in
        t.dark ? UIColor(r: 255, g: 115, b: 90) : UIColor(r: 225, g: 80, b: 60)
    })

    static let heartEmpty = Color(UIColor { t in
        t.dark ? UIColor(r: 48, g: 42, b: 37) : UIColor(r: 222, g: 215, b: 207)
    })

    static let inputBg = Color(UIColor { t in
        t.dark ? UIColor(r: 20, g: 17, b: 15) : UIColor(r: 245, g: 240, b: 234)
    })

    // Gradients
    static let warmGradient = LinearGradient(
        colors: [Color(hex: "E8735A"), Color(hex: "F5A623")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let sunsetGradient = LinearGradient(
        colors: [Color(hex: "F5A623"), Color(hex: "E8735A"), Color(hex: "C94B8C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let artGradients: [[Color]] = [
        [Color(hex: "E8735A"), Color(hex: "F5A623")],
        [Color(hex: "7B68EE"), Color(hex: "E040FB")],
        [Color(hex: "00BCD4"), Color(hex: "26A69A")],
        [Color(hex: "FF6B6B"), Color(hex: "FFE66D")],
        [Color(hex: "A18CD1"), Color(hex: "FBC2EB")],
        [Color(hex: "43E97B"), Color(hex: "38F9D7")],
        [Color(hex: "FA709A"), Color(hex: "FEE140")],
        [Color(hex: "4FACFE"), Color(hex: "00F2FE")],
        [Color(hex: "F093FB"), Color(hex: "F5576C")],
        [Color(hex: "5EE7DF"), Color(hex: "B490CA")],
    ]

    // Card shadow
    static func cardShadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.4) : .black.opacity(0.04)
    }
}

// MARK: - Avatars

struct AvatarDef: Identifiable {
    let id: Int
    let symbol: String
    let colors: [Color]
    let name: String
}

extension Theme {
    static let avatars: [AvatarDef] = [
        .init(id: 0, symbol: "cat.fill", colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")], name: "kitty"),
        .init(id: 1, symbol: "hare.fill", colors: [Color(hex: "7B68EE"), Color(hex: "E040FB")], name: "bunny"),
        .init(id: 2, symbol: "bird.fill", colors: [Color(hex: "4FACFE"), Color(hex: "00F2FE")], name: "birdie"),
        .init(id: 3, symbol: "leaf.fill", colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")], name: "leaf"),
        .init(id: 4, symbol: "star.fill", colors: [Color(hex: "F5A623"), Color(hex: "F5D020")], name: "star"),
        .init(id: 5, symbol: "moon.fill", colors: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")], name: "luna"),
        .init(id: 6, symbol: "flame.fill", colors: [Color(hex: "E8735A"), Color(hex: "F5A623")], name: "flame"),
        .init(id: 7, symbol: "heart.fill", colors: [Color(hex: "FA709A"), Color(hex: "FEE140")], name: "heart"),
        .init(id: 8, symbol: "sparkles", colors: [Color(hex: "FFD700"), Color(hex: "FF6B6B")], name: "sparkle"),
        .init(id: 9, symbol: "pawprint.fill", colors: [Color(hex: "00BCD4"), Color(hex: "26A69A")], name: "paw"),
        .init(id: 10, symbol: "bolt.fill", colors: [Color(hex: "F093FB"), Color(hex: "F5576C")], name: "bolt"),
        .init(id: 11, symbol: "tortoise.fill", colors: [Color(hex: "5EE7DF"), Color(hex: "B490CA")], name: "shell"),
    ]
}

// MARK: - GradientIcon (emoji replacement)

struct GradientIcon: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 20
    var bgSize: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: colors.map { $0.opacity(0.18) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: bgSize, height: bgSize)

            Image(systemName: symbol)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: colors,
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    }
}

// MARK: - Ambient gradient background

struct AmbientBackground: View {
    @Environment(\.colorScheme) var scheme
    @State private var drift = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            GeometryReader { geo in
                // Warm primary glow
                Circle()
                    .fill(Theme.accent.opacity(scheme == .dark ? 0.10 : 0.10))
                    .frame(width: geo.size.width * 0.95)
                    .blur(radius: 140)
                    .offset(
                        x: -geo.size.width * (drift ? 0.32 : 0.28),
                        y: -geo.size.height * (drift ? 0.10 : 0.14)
                    )

                // Amber secondary
                Circle()
                    .fill(Theme.gold.opacity(scheme == .dark ? 0.07 : 0.07))
                    .frame(width: geo.size.width * 0.75)
                    .blur(radius: 120)
                    .offset(
                        x: geo.size.width * (drift ? 0.4 : 0.32),
                        y: geo.size.height * (drift ? 0.32 : 0.38)
                    )

                // Deep ember accent for depth
                Circle()
                    .fill(Color(hex: "C94B8C").opacity(scheme == .dark ? 0.05 : 0.04))
                    .frame(width: geo.size.width * 0.55)
                    .blur(radius: 100)
                    .offset(
                        x: geo.size.width * (drift ? 0.05 : 0.12),
                        y: geo.size.height * (drift ? 0.72 : 0.68)
                    )
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}

// MARK: - Glass card modifier

struct GlassCard: ViewModifier {
    @Environment(\.colorScheme) var scheme
    var cornerRadius: CGFloat = 22
    var glowColor: Color? = nil

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(scheme == .dark ? 0.25 : 0.7),
                                        .white.opacity(scheme == .dark ? 0.04 : 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: (glowColor ?? .black).opacity(scheme == .dark ? 0.35 : 0.08),
                            radius: glowColor == nil ? 18 : 28, y: 8)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 22, glowColor: Color? = nil) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, glowColor: glowColor))
    }
}

// MARK: - Glowing thin icon

/// Thin SF Symbol with a soft colored glow underneath. Replaces the chunky
/// pastel-circle icon style for a more grown-up look.
struct GlowIcon: View {
    let symbol: String
    let tint: Color
    var size: CGFloat = 22

    @Environment(\.colorScheme) private var scheme
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(scheme == .dark ? 0.35 : 0.28))
                .frame(width: size * 2.6, height: size * 2.6)
                .blur(radius: size * 0.9)
                .scaleEffect(pulse ? 1.08 : 0.92)

            Image(systemName: symbol)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.7)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: tint.opacity(0.6), radius: 8)
        }
        .frame(width: size * 2.2, height: size * 2.2)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Card modifier

struct CrumbsCard: ViewModifier {
    @Environment(\.colorScheme) var scheme
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.cardBg)
                    .shadow(color: Theme.cardShadow(scheme), radius: scheme == .dark ? 1 : 16, y: scheme == .dark ? 0 : 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(scheme == .dark ? Color.white.opacity(0.06) : .clear, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func crumbsCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(CrumbsCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Helpers

private extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}

private extension UITraitCollection {
    var dark: Bool { userInterfaceStyle == .dark }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
