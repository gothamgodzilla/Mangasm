import SwiftUI
import XCTest
@testable import MangasmApp

final class SkylineTests: XCTestCase {
    func testFourCities() { XCTAssertEqual(City.allCases.count, 4) }
    func testDubaiTag() { XCTAssertEqual(City.dubai.tag, "where the signal shouldn't reach") }
    func testSkylinePathNonEmpty() {
        let r = CGRect(x: 0, y: 0, width: 400, height: 150)
        XCTAssertFalse(Skyline(city: .tokyo).path(in: r).isEmpty)
    }
}
