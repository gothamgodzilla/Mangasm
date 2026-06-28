import XCTest
@testable import MangasmApp

final class ReferralCodeTests: XCTestCase {
    func testNormalizeUppercasesAndTrims() {
        XCTAssertEqual(ReferralCode.normalize("  taz "), "TAZ")
        XCTAssertEqual(ReferralCode.normalize("elmerfudd"), "ELMERFUDD")
    }

    func testNormalizeRejectsInvalid() {
        XCTAssertNil(ReferralCode.normalize(""))
        XCTAssertNil(ReferralCode.normalize("no spaces"))
        XCTAssertNil(ReferralCode.normalize("x"))
    }

    func testParseFromPromoURL() {
        let url = URL(string: "https://mangasm.app/promo?code=bugs")!
        XCTAssertEqual(ReferralCode.parse(from: url), "BUGS")
    }

    func testPromoURLRoundTrip() {
        let url = ReferralCode.promoURL(for: "taz")
        XCTAssertEqual(url?.absoluteString, "https://mangasm.app/promo?code=TAZ")
    }
}