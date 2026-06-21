import SwiftUI

public extension Color {
    init(hex: String) {
        let s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255; g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255;  a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255; g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255;         a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

public enum MGColor {
    public static let gold = Color(hex: "#C9A84C")
    public static let goldDeep = Color(hex: "#9A7B2C")
    public static let goldBright = Color(hex: "#E4C97E")
    public static let ink = Color(hex: "#2A2117")
    public static let inkSoft = Color(red: 42/255, green: 33/255, blue: 23/255, opacity: 0.70)
    public static let inkFaint = Color(red: 42/255, green: 33/255, blue: 23/255, opacity: 0.50)
    public static let spotify = Color(hex: "#138A3E")
    public static let launchOrange = Color(hex: "#F08A38")
    public static let launchOrangeDeep = Color(hex: "#C95E1E")
    public static let skylineInk = Color(hex: "#120A14")
}

public enum MGFont {
    // Custom fonts fall back to system if not registered.
    public static func serif(_ size: CGFloat, _ w: Font.Weight = .bold) -> Font {
        .custom("CormorantGaramond-Bold", size: size).weight(w)
    }
    public static func sans(_ size: CGFloat, _ w: Font.Weight = .semibold) -> Font {
        .custom("Mulish", size: size).weight(w)
    }
    public static func mono(_ size: CGFloat, _ w: Font.Weight = .regular) -> Font {
        .custom("SpaceMono-Regular", size: size).weight(w)
    }
}

public enum MGGradient {
    public static let holo = LinearGradient(
        colors: [Color(hex: "#787C8C"), Color(hex: "#FFFFFF"), Color(hex: "#96B2D2"), MGColor.gold],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    public static let goldButton = LinearGradient(
        colors: [MGColor.goldBright, MGColor.goldDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    public static let launchCTA = LinearGradient(
        colors: [MGColor.launchOrange, MGColor.launchOrangeDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}
