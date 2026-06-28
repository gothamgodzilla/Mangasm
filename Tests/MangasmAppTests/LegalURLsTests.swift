import XCTest
@testable import MangasmApp

final class LegalURLsTests: XCTestCase {
    func testLegalURLsUseMangasmDomain() {
        XCTAssertTrue(LegalURLs.privacy.hasPrefix("https://www.mangasm.app/"))
        XCTAssertTrue(LegalURLs.terms.hasPrefix("https://www.mangasm.app/"))
        XCTAssertTrue(LegalURLs.moderation.hasPrefix("https://www.mangasm.app/"))
        XCTAssertEqual(LegalURLs.support, "mailto:support@mangasm.app")
        XCTAssertEqual(LegalURLs.ai, "mailto:ai@mangasm.app")
        XCTAssertEqual(LegalURLs.aiLabel, "AI@Mangasm.app")
    }
}