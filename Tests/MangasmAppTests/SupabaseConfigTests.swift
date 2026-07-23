import XCTest
@testable import MangasmApp

final class SupabaseConfigTests: XCTestCase {
    func testRejectsEmptyAndPlaceholders() {
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey(""))
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey("   "))
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey("$(SUPABASE_PUBLISHABLE_KEY)"))
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey("PLACEHOLDER_PASTE_ANON_KEY"))
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey("sb_publishable_YOUR_KEY"))
        XCTAssertFalse(SupabaseConfig.isUsablePublishableKey("short"))
    }

    func testAcceptsLongishRealLookingKeys() {
        let jwtish = String(repeating: "a", count: 40) + ".b." + String(repeating: "c", count: 40)
        XCTAssertTrue(SupabaseConfig.isUsablePublishableKey(jwtish))
        XCTAssertTrue(SupabaseConfig.isUsablePublishableKey("sb_publishable_" + String(repeating: "x", count: 30)))
    }

    func testDefaultURLPointsAtLiveHost() {
        XCTAssertEqual(
            SupabaseConfig.defaultURL.host,
            "dvomzrvslwdabwcwtvrg.supabase.co"
        )
    }
}

extension SupabaseConfigTests {
    /// Build-23 regression: xcconfig comment truncation produced "https:",
    /// which URL(string:) happily parses — resolveURL must reject it.
    func testTruncatedXcconfigURLFallsBackToDefault() {
        XCTAssertEqual(SupabaseConfig.resolveURL("https:"), SupabaseConfig.defaultURL)
        XCTAssertEqual(SupabaseConfig.resolveURL("https://"), SupabaseConfig.defaultURL)
        XCTAssertEqual(SupabaseConfig.resolveURL("$(SUPABASE_URL)"), SupabaseConfig.defaultURL)
        XCTAssertEqual(SupabaseConfig.resolveURL(nil), SupabaseConfig.defaultURL)
        XCTAssertEqual(SupabaseConfig.resolveURL(""), SupabaseConfig.defaultURL)
    }

    func testRealURLIsAccepted() {
        let real = "https://dvomzrvslwdabwcwtvrg.supabase.co"
        XCTAssertEqual(SupabaseConfig.resolveURL(real).absoluteString, real)
    }
}
