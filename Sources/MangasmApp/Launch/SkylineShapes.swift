import SwiftUI

// MARK: - City

/// Four landmark cities for the sign-in slideshow.
/// sky: 3-stop gradient colors [bottom dark, mid, horizon].
public enum City: CaseIterable, Hashable, Sendable {
    case dubai, london, mykonos, tokyo

    public var name: String {
        switch self {
        case .dubai:   return "Dubai"
        case .london:  return "London"
        case .mykonos: return "Mykonos"
        case .tokyo:   return "Tokyo"
        }
    }

    public var coord: String {
        switch self {
        case .dubai:   return "25.20° N · 55.27° E"
        case .london:  return "51.50° N · 0.12° W"
        case .mykonos: return "37.44° N · 25.32° E"
        case .tokyo:   return "35.67° N · 139.65° E"
        }
    }

    /// Italic slide caption. Straight apostrophe required — test contract.
    public var tag: String {
        switch self {
        case .dubai:   return "where the signal shouldn't reach"
        case .london:  return "after-hours, members only"
        case .mykonos: return "white walls, gold nights"
        case .tokyo:   return "neon, velvet & rain"
        }
    }

    /// 3 sky gradient stops: [0% darkest, 56% mid, 100% horizon].
    public var sky: [Color] {
        switch self {
        case .dubai:   return [Color(hex: "#241a36"), Color(hex: "#6e3550"), Color(hex: "#e0894a")]
        case .london:  return [Color(hex: "#161f3c"), Color(hex: "#3c3a64"), Color(hex: "#bf6a7e")]
        case .mykonos: return [Color(hex: "#102634"), Color(hex: "#2f6f7c"), Color(hex: "#e7bd6e")]
        case .tokyo:   return [Color(hex: "#191334"), Color(hex: "#5a2a4c"), Color(hex: "#d4585a")]
        }
    }
}

// MARK: - Skyline

/// Per-city silhouette shape drawn in the 400×150 prototype coordinate space,
/// scaled proportionally into `rect`.
///
/// Approximation notes:
/// - London Eye spokes, Tokyo Tower lattice/cross-bars, and Skytree ring are
///   rendered as solid filled silhouettes (the Shape contract requires a single
///   filled path; stroke-only elements from the SVG prototype are converted to
///   solid rectangles/disks).
/// - Mykonos windmill blades are simplified to 6 thin rectangles rotated
///   around the hub.
public struct Skyline: Shape {
    public let city: City

    public init(city: City) { self.city = city }

    public func path(in rect: CGRect) -> Path {
        // Scale factors from the 400×150 design space.
        let sx = rect.width / 400
        let sy = rect.height / 150
        let ox = rect.minX
        let oy = rect.minY

        /// Convert design-space point to SwiftUI coordinates.
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: ox + x * sx, y: oy + y * sy)
        }

        /// band(x, w, h) → rect from bottom (y=150) upward.
        /// Prototype: y = top - h = 150 - h; height = h.
        func band(_ x: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: ox + x * sx, y: oy + (150 - h) * sy, width: w * sx, height: h * sy)
        }

        var p = Path()

        switch city {
        case .dubai:
            dubaiPath(&p, band: band, pt: pt, sx: sx, sy: sy, ox: ox, oy: oy)
        case .london:
            londonPath(&p, band: band, pt: pt, sx: sx, sy: sy, ox: ox, oy: oy)
        case .mykonos:
            mykonosPath(&p, band: band, pt: pt, sx: sx, sy: sy, ox: ox, oy: oy)
        case .tokyo:
            tokyoPath(&p, band: band, pt: pt, sx: sx, sy: sy, ox: ox, oy: oy)
        }

        return p
    }
}

// MARK: - Dubai

private func dubaiPath(
    _ p: inout Path,
    band: (CGFloat, CGFloat, CGFloat) -> CGRect,
    pt: (CGFloat, CGFloat) -> CGPoint,
    sx: CGFloat, sy: CGFloat, ox: CGFloat, oy: CGFloat
) {
    // Background building bands (left cluster)
    for (x, w, h) in [(6, 16, 30), (26, 12, 46), (42, 18, 62), (64, 14, 40), (92, 20, 78), (118, 12, 52)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }

    // Burj Khalifa tapering tower (triangle silhouette)
    p.move(to: pt(150, 150))
    p.addLine(to: pt(156, 150))
    p.addLine(to: pt(153, 24))
    p.closeSubpath()

    // Burj shaft as thin rect for solidity
    p.addRect(band(150, 6, 86))

    // Needle tip
    p.move(to: pt(152, 24))
    p.addLine(to: pt(153.5, 6))
    p.addLine(to: pt(155, 24))
    p.closeSubpath()

    // Background building bands (right cluster)
    for (x, w, h) in [(170, 16, 58), (192, 22, 92), (220, 14, 44), (238, 18, 70),
                      (262, 12, 38), (280, 22, 100), (308, 14, 54), (326, 18, 72),
                      (350, 16, 46), (372, 20, 84)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }
}

// MARK: - London

private func londonPath(
    _ p: inout Path,
    band: (CGFloat, CGFloat, CGFloat) -> CGRect,
    pt: (CGFloat, CGFloat) -> CGPoint,
    sx: CGFloat, sy: CGFloat, ox: CGFloat, oy: CGFloat
) {
    // Left building cluster
    for (x, w, h) in [(6, 20, 40), (30, 16, 30), (50, 14, 52)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }

    // London Eye — filled disk (approximation: solid wheel silhouette)
    // Prototype: circle cx=96 cy=92 r=34 (stroke only) + spoke lines + support rect below
    let eyeCX: CGFloat = 96
    let eyeCY: CGFloat = 92
    let eyeR: CGFloat = 34
    // Outer ring as filled annulus approximation — use full disk (solid silhouette)
    let eyeCenter = CGPoint(x: ox + eyeCX * sx, y: oy + eyeCY * sy)
    p.addEllipse(in: CGRect(
        x: eyeCenter.x - eyeR * sx,
        y: eyeCenter.y - eyeR * sy,
        width: eyeR * 2 * sx,
        height: eyeR * 2 * sy
    ))

    // Eye support base (rect below wheel, y=124 h=26)
    p.addRect(band(80, 32, 26))  // x=80 w=32 h=26 — but bottom of rect is 150

    // Big Ben shaft + header + spire
    p.addRect(band(150, 16, 92))     // main tower
    p.addRect(band(149, 18, 9))      // clock header (y = 150-100-9 = 41, h=9 → but from band(149,18,9) top = 150-9=141)
    // Actually Big Ben: shaft y58 h92 → band(150,16,92); header y50 h9 → band(149,18,9)
    // Note: in the prototype rect x=150 y=58 width=16 height=92 + rect x=149 y=50 width=18 height=9
    // Bands represent from bottom: h=92 reaches y=58 from bottom (150-92=58) ✓
    // Header: y=50, h=9 → 150-50-9=91 up from top? No: rect is at y=50, h=9 → top=50, bottom=59
    // In band terms: from bottom h = 150-50 = 100 but rect is only 9 tall starting at y=50
    // So the header is NOT a full band — it's a small rect at design y=50
    // Let's add header rect explicitly:
    p.addRect(CGRect(
        x: ox + 149 * sx, y: oy + 50 * sy,
        width: 18 * sx, height: 9 * sy
    ))
    // Spire triangle above header at y=30-50
    p.move(to: pt(150, 50))
    p.addLine(to: pt(158, 30))
    p.addLine(to: pt(166, 50))
    p.closeSubpath()

    // The Shard
    p.move(to: pt(200, 150))
    p.addLine(to: pt(214, 150))
    p.addLine(to: pt(210, 36))
    p.closeSubpath()

    // Right building cluster
    for (x, w, h) in [(230, 18, 60), (254, 14, 42), (272, 22, 84),
                      (300, 16, 50), (322, 20, 72), (350, 14, 38), (368, 22, 96)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }
}

// MARK: - Mykonos

private func mykonosPath(
    _ p: inout Path,
    band: (CGFloat, CGFloat, CGFloat) -> CGRect,
    pt: (CGFloat, CGFloat) -> CGPoint,
    sx: CGFloat, sy: CGFloat, ox: CGFloat, oy: CGFloat
) {
    // White cubic building clusters
    for (x, w, h) in [(6, 30, 40), (40, 26, 52), (70, 34, 44), (108, 24, 60),
                      (150, 30, 40), (210, 28, 50), (244, 34, 42),
                      (300, 26, 56), (332, 30, 46), (368, 24, 52)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx * 2, height: sy * 2))
    }

    // Church dome — arc from y=150 up to y=122, dome peaks at y≈108
    // Prototype: path d="M176 150 L176 122 a14 14 0 0 1 28 0 L204 150 Z"
    p.move(to: pt(176, 150))
    p.addLine(to: pt(176, 122))
    p.addRelativeArc(
        center: CGPoint(x: ox + 190 * sx, y: oy + 122 * sy),
        radius: 14 * sx,
        startAngle: .degrees(180),
        delta: .degrees(-180)  // sweep left to right (arc "0 0 1" = counterclockwise in SVG = clockwise in SwiftUI y-down)
    )
    p.addLine(to: pt(204, 150))
    p.closeSubpath()

    // Bell tower below dome (rect x=186 y=104 w=8 h=10)
    p.addRect(CGRect(
        x: ox + 186 * sx, y: oy + 104 * sy,
        width: 8 * sx, height: 10 * sy
    ))

    // Windmill tower
    p.addRect(band(278, 18, 52))
    // Hub disk (approximation: small filled circle)
    let hubCenter = CGPoint(x: ox + 287 * sx, y: oy + 98 * sy)
    p.addEllipse(in: CGRect(
        x: hubCenter.x - 5 * sx, y: hubCenter.y - 5 * sy,
        width: 10 * sx, height: 10 * sy
    ))
    // 6 blades — thin rects rotated around hub (approximated as thin rects at 60° intervals)
    // Prototype: 6 rect x=285.5 y=98 w=3 h=30 rotated i*60° around (287, 98)
    // In SwiftUI Path we cannot rotate individual rects directly; approximate with thin wedges
    // using line segments from hub to blade tips at each angle
    let bladeLen: CGFloat = 30
    let bladeW: CGFloat = 3
    for i in 0..<6 {
        let angleDeg = Double(i) * 60.0
        let angleRad = angleDeg * .pi / 180
        let cosA = CGFloat(cos(angleRad))
        let sinA = CGFloat(sin(angleRad))
        // Blade as parallelogram from hub outward
        let tipX = 287 + bladeLen * sinA
        let tipY = 98 - bladeLen * cosA  // upward in SVG
        // Perp direction for width
        let perpX = cosA * (bladeW / 2)
        let perpY = sinA * (bladeW / 2)
        p.move(to: pt(287 + perpX, 98 + perpY))
        p.addLine(to: pt(tipX + perpX, tipY + perpY))
        p.addLine(to: pt(tipX - perpX, tipY - perpY))
        p.addLine(to: pt(287 - perpX, 98 - perpY))
        p.closeSubpath()
    }
}

// MARK: - Tokyo

private func tokyoPath(
    _ p: inout Path,
    band: (CGFloat, CGFloat, CGFloat) -> CGRect,
    pt: (CGFloat, CGFloat) -> CGPoint,
    sx: CGFloat, sy: CGFloat, ox: CGFloat, oy: CGFloat
) {
    // Left building cluster
    for (x, w, h) in [(6, 18, 52), (28, 14, 34), (46, 20, 68), (72, 16, 44)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }

    // Tokyo Tower — tapered triangle (solid fill approximation; prototype was stroke-only)
    p.move(to: pt(104, 150))
    p.addLine(to: pt(124, 150))
    p.addLine(to: pt(116, 38))
    p.closeSubpath()
    // Needle above apex
    p.move(to: pt(116, 38))
    p.addLine(to: pt(115, 18))
    p.addLine(to: pt(117, 18))
    p.addLine(to: pt(116, 38))
    p.closeSubpath()
    // Cross-bar platforms (filled rects for the horizontal observation decks)
    p.addRect(CGRect(
        x: ox + 108 * sx, y: oy + 95 * sy,
        width: 24 * sx, height: 2.5 * sy
    ))
    p.addRect(CGRect(
        x: ox + 111 * sx, y: oy + 69 * sy,
        width: 18 * sx, height: 2.5 * sy
    ))

    // Mid building cluster
    for (x, w, h) in [(150, 16, 46), (172, 22, 80), (200, 14, 40), (218, 18, 60)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }

    // Skytree mast (thin vertical rect)
    p.addRect(band(262, 6, 130))
    // Skytree observation deck ring — filled disk (approximation of stroke circle cx=265 cy=58 r=9)
    let stCenter = CGPoint(x: ox + 265 * sx, y: oy + 58 * sy)
    p.addEllipse(in: CGRect(
        x: stCenter.x - 9 * sx, y: stCenter.y - 9 * sy,
        width: 18 * sx, height: 18 * sy
    ))
    // Skytree antenna above (y=6 to y=20)
    p.addRect(CGRect(
        x: ox + 264.2 * sx, y: oy + 6 * sy,
        width: 1.6 * sx, height: 14 * sy
    ))

    // Right building cluster
    for (x, w, h) in [(290, 20, 72), (318, 14, 40), (336, 22, 90), (366, 16, 50)] as [(CGFloat, CGFloat, CGFloat)] {
        p.addRoundedRect(in: band(x, w, h), cornerSize: CGSize(width: sx, height: sy))
    }
}
