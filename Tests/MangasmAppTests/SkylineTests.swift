import SwiftUI
import XCTest
@testable import MangasmApp

final class SkylineTests: XCTestCase {
    func testFiveCities() { XCTAssertEqual(City.allCases.count, 5) }
    func testDubaiTag() { XCTAssertEqual(City.dubai.tag, "where the signal shouldn't reach") }
    func testBlackRockCity() {
        XCTAssertEqual(City.blackRockCity.name, "Black Rock City")
        XCTAssertEqual(City.blackRockCity.tag, "dust, fire & deep house")
    }
    func testSkylinePathNonEmpty() {
        let r = CGRect(x: 0, y: 0, width: 400, height: 150)
        XCTAssertFalse(Skyline(city: .tokyo).path(in: r).isEmpty)
        XCTAssertFalse(Skyline(city: .blackRockCity).path(in: r).isEmpty)
    }
}
