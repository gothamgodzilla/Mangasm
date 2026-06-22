import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Loads a RAW resource file (not an asset catalog) from the package bundle as
/// a SwiftUI `Image`. `Image(name:bundle:)` only finds asset-catalog images, so
/// a bundled `lambo_hero.jpg` file silently renders empty with that initializer.
func bundledFileImage(_ name: String, _ ext: String) -> Image? {
    guard let url = Bundle.module.url(forResource: name, withExtension: ext) else { return nil }
    #if canImport(UIKit)
    if let img = UIImage(contentsOfFile: url.path) { return Image(uiImage: img) }
    #elseif canImport(AppKit)
    if let img = NSImage(contentsOf: url) { return Image(nsImage: img) }
    #endif
    return nil
}

// MARK: - LamborghiniBackground
// Layered ZStack: lambo_hero image (bottom-anchored, scaledToFill) with day/night
// brightness/saturation; carbon-fibre weave overlay; day/night vignette gradient;
// night glow radial; inset edge shadow.
// Falls back to a dark gradient if the image asset is absent from Bundle.module.

public struct LamborghiniBackground: View {
    public let night: Bool

    public init(night: Bool) {
        self.night = night
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── 1. Hero image (bottom-anchored, scaledToFill) ───────────────
                if let hero = bundledFileImage("lambo_hero", "jpg") {
                    hero
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                        .clipped()
                        .colorMultiply(Color(white: night ? 0.62 : 1.0))
                        .saturation(night ? 1.18 : 1.16)
                        .contrast(night ? 1.08 : 1.04)
                } else {
                    // Fallback: dark gradient when asset is missing
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "#0D0D12"), location: 0),
                            .init(color: Color(hex: "#1A1520"), location: 0.45),
                            .init(color: Color(hex: "#0A080E"), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                }

                // ── 2. Carbon-fibre weave texture ───────────────────────────────
                CarbonWeaveOverlay()
                    .blendMode(.overlay)
                    .opacity(0.5)

                // ── 3. Day/Night vignette gradient ──────────────────────────────
                if night {
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 8/255, green: 10/255, blue: 14/255, opacity: 0.62), location: 0),
                            .init(color: Color(red: 10/255, green: 12/255, blue: 16/255, opacity: 0.28), location: 0.34),
                            .init(color: Color(red: 6/255, green: 8/255, blue: 12/255, opacity: 0.50), location: 0.70),
                            .init(color: Color(red: 3/255, green: 4/255, blue: 7/255, opacity: 0.80), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                } else {
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 8/255, green: 10/255, blue: 14/255, opacity: 0.46), location: 0),
                            .init(color: Color(red: 14/255, green: 18/255, blue: 24/255, opacity: 0.04), location: 0.40),
                            .init(color: Color(red: 8/255, green: 11/255, blue: 16/255, opacity: 0.12), location: 0.76),
                            .init(color: Color(red: 4/255, green: 6/255, blue: 10/255, opacity: 0.40), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                }

                // ── 4. Night glow radial (amber/orange warmth top-right) ─────────
                if night {
                    RadialGradient(
                        colors: [
                            Color(red: 232/255, green: 140/255, blue: 90/255, opacity: 0.20),
                            Color.clear,
                        ],
                        center: .init(x: 0.70, y: 0.18),
                        startRadius: 0,
                        endRadius: geo.size.width * 0.9
                    )
                    .blendMode(.screen)
                }

                // ── 5. Inset edge shadow (approximated via radial dark ring) ─────
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0, green: 0, blue: 0, opacity: night ? 0.62 : 0.50),
                    ],
                    center: .center,
                    startRadius: geo.size.width * 0.28,
                    endRadius: geo.size.width * 0.82
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }
}

// MARK: - CarbonWeaveOverlay
// Repeating diagonal carbon-fibre pattern drawn once into a Canvas tile.
// Equivalent to the CSS:
//   repeating-linear-gradient(45deg, rgba(255,255,255,0.05) 0 2px, rgba(0,0,0,0.05) 2px 4px)
//   + repeating-linear-gradient(-45deg, rgba(255,255,255,0.04) 0 2px, rgba(0,0,0,0.06) 2px 4px)
private struct CarbonWeaveOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            // We tile a 6×6 pt cell to fill the canvas.
            let cell: CGFloat = 6
            let cols = Int(ceil(size.width / cell)) + 1
            let rows = Int(ceil(size.height / cell)) + 1

            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * cell
                    let y = CGFloat(row) * cell
                    // +45° light stripe
                    var pathLight = Path()
                    pathLight.move(to: CGPoint(x: x, y: y))
                    pathLight.addLine(to: CGPoint(x: x + cell, y: y + cell))
                    ctx.stroke(pathLight, with: .color(white: 1, opacity: 0.05), lineWidth: 2)
                    // +45° dark stripe offset
                    var pathDark = Path()
                    pathDark.move(to: CGPoint(x: x + 2, y: y))
                    pathDark.addLine(to: CGPoint(x: x + cell, y: y + cell - 2))
                    ctx.stroke(pathDark, with: .color(white: 0, opacity: 0.05), lineWidth: 2)
                    // -45° light stripe
                    var pathLight2 = Path()
                    pathLight2.move(to: CGPoint(x: x + cell, y: y))
                    pathLight2.addLine(to: CGPoint(x: x, y: y + cell))
                    ctx.stroke(pathLight2, with: .color(white: 1, opacity: 0.04), lineWidth: 2)
                    // -45° dark stripe offset
                    var pathDark2 = Path()
                    pathDark2.move(to: CGPoint(x: x + cell - 2, y: y))
                    pathDark2.addLine(to: CGPoint(x: x, y: y + cell - 2))
                    ctx.stroke(pathDark2, with: .color(white: 0, opacity: 0.06), lineWidth: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
