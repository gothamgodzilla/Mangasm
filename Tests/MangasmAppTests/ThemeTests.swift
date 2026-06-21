import SwiftUI
import XCTest
@testable import MangasmApp

final class ThemeTests: XCTestCase {
    func testHexParsesRRGGBB() {
        let c = Color(hex: "#C9A84C")
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0xC9/255, accuracy: 0.01)
        XCTAssertEqual(g, 0xA8/255, accuracy: 0.01)
        XCTAssertEqual(b, 0x4C/255, accuracy: 0.01)
        #endif
    }
    func testHexIgnoresLeadingHash() {
        XCTAssertNoThrow(Color(hex: "C9A84C"))
    }
}
