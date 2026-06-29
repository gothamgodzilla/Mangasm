import XCTest
@testable import MangasmApp

final class SafetyMappingTests: XCTestCase {
    func testReportReasonLabelsMapToDatabaseEnum() {
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: ReportReason.harassment.label), "harassment")
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: ReportReason.spam.label), "spam")
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: ReportReason.fakeProfile.label), "fake_profile")
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: ReportReason.underage.label), "underage")
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: ReportReason.other.label), "other")
    }

    func testUnknownReportReasonFallsBackToOther() {
        XCTAssertEqual(SafetyReasonMapper.dbValue(from: "Unknown reason"), "other")
    }
}