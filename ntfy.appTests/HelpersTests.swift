import Testing
@testable import ntfy_app

struct HelpersTests {

    @Test func testTimestampToDate() async throws {
        let timestamp: Int = 1609459200
        let expectedDate = "2021-01-01 01:00:00"
        let result = timestampToDate(timestamp: timestamp)
        #expect(result == expectedDate, "Timestamp to date conversion is incorrect")

        let anotherTimestamp: Int = 1612137600
        let anotherExpectedDate = "2021-02-01 01:00:00"
        let anotherResult = timestampToDate(timestamp: anotherTimestamp)
        #expect(anotherResult == anotherExpectedDate, "Timestamp to date conversion is incorrect")
    }
}
