import SwiftUI

// MARK: - CompatibilityRing
// Animated gold trimmed-circle stroke with serif percent center.
// Prototype ref: mangasm-match.jsx — stroke-dashoffset on a 64×64 SVG circle (R=26),
// transition cubic-bezier(.2,.8,.2,1) 1s.
// SwiftUI equivalent: .trim(from:to:) + .timingCurve(0.2,0.8,0.2,1,duration:1.0).
//
// Re-animation: onChange(of: percent) resets filled→false then fires true after 120ms,
// mirroring the prototype's useEffect([start]) delay approach.

public struct CompatibilityRing: View {
    let percent: Int
    var size: CGFloat

    public init(percent: Int, size: CGFloat = 64) {
        self.percent = percent
        self.size = size
    }

    @State private var filled: Bool = false

    // Radius = size * 26/64 — keeps R proportional to the prototype's 26/64 ratio.
    private var radius: CGFloat { size * 26 / 64 }
    private var strokeWidth: CGFloat { size * 4 / 64 }
    private var percentFraction: CGFloat { CGFloat(filled ? percent : 0) / 100 }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(MGColor.ink.opacity(0.16), lineWidth: strokeWidth)

            // Animated gold arc
            Circle()
                .trim(from: 0, to: percentFraction)
                .stroke(
                    LinearGradient(
                        colors: [MGColor.goldBright, MGColor.goldDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: MGColor.gold.opacity(0.8), radius: 4, x: 0, y: 0)
                // cubic-bezier(.2,.8,.2,1) 1s — matches prototype
                .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.0), value: filled)

            // Center label
            VStack(spacing: 1) {
                Text("\(percent)")
                    .font(MGFont.serif(size * 20 / 64, .bold))
                    .foregroundStyle(MGGradient.goldButton)
                    .lineLimit(1)
                Text("MATCH")
                    .font(MGFont.mono(size * 5.5 / 64))
                    .tracking((size * 5.5 / 64) * 0.10)
                    .foregroundStyle(MGColor.inkFaint)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                filled = true
            }
        }
        .onChange(of: percent) { _, _ in
            // Reset then re-fire so the ring re-animates on candidate change
            filled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                filled = true
            }
        }
    }
}
