import XCTest
@testable import ClipboardCore

final class ClipItemTests: XCTestCase {

    // MARK: - Init

    func testInitSetsTextAndGeneratesIdAndTimestamp() {
        let item = ClipItem(text: "hello")
        XCTAssertEqual(item.text, "hello")
        XCTAssertFalse(item.id.uuidString.isEmpty)
        XCTAssertTrue(item.timestamp.timeIntervalSinceNow < 1)
    }

    func testInitWithExplicitValues() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1000)
        let item = ClipItem(id: id, text: "test", timestamp: date)
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, "test")
        XCTAssertEqual(item.timestamp, date)
    }

    // MARK: - Preview

    func testPreviewShortText() {
        let item = ClipItem(text: "short")
        XCTAssertEqual(item.preview, "short")
    }

    func testPreviewTrimsWhitespace() {
        let item = ClipItem(text: "  hello world  \n")
        XCTAssertEqual(item.preview, "hello world")
    }

    func testPreviewTruncatesLongText() {
        let longText = String(repeating: "a", count: 200)
        let item = ClipItem(text: longText)
        XCTAssertEqual(item.preview, String(repeating: "a", count: 120) + "...")
        XCTAssertEqual(item.preview.count, 123)
    }

    func testPreviewExactly120Chars() {
        let text = String(repeating: "b", count: 120)
        let item = ClipItem(text: text)
        XCTAssertEqual(item.preview, text)
    }

    func testPreview121Chars() {
        let text = String(repeating: "c", count: 121)
        let item = ClipItem(text: text)
        XCTAssertTrue(item.preview.hasSuffix("..."))
        XCTAssertEqual(item.preview.count, 123)
    }

    // MARK: - TimeAgo

    func testTimeAgoJustNow() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date())
        XCTAssertEqual(item.timeAgo, "just now")
    }

    func testTimeAgoMinutes() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-120))
        XCTAssertEqual(item.timeAgo, "2m ago")
    }

    func testTimeAgoHours() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-7200))
        XCTAssertEqual(item.timeAgo, "2h ago")
    }

    func testTimeAgoDays() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-172800))
        XCTAssertEqual(item.timeAgo, "2d ago")
    }

    func testTimeAgoBoundary59Seconds() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-59))
        XCTAssertEqual(item.timeAgo, "just now")
    }

    func testTimeAgoBoundary60Seconds() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-60))
        XCTAssertEqual(item.timeAgo, "1m ago")
    }

    func testTimeAgoBoundary3599Seconds() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-3599))
        XCTAssertEqual(item.timeAgo, "59m ago")
    }

    func testTimeAgoBoundary3600Seconds() {
        let item = ClipItem(id: UUID(), text: "x", timestamp: Date().addingTimeInterval(-3600))
        XCTAssertEqual(item.timeAgo, "1h ago")
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = ClipItem(id: UUID(), text: "test data", timestamp: Date(timeIntervalSince1970: 1700000000))

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ClipItem.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testCodableArrayRoundTrip() throws {
        let items = [
            ClipItem(id: UUID(), text: "first", timestamp: Date(timeIntervalSince1970: 1700000000)),
            ClipItem(id: UUID(), text: "second", timestamp: Date(timeIntervalSince1970: 1700001000)),
        ]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(items)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([ClipItem].self, from: data)

        XCTAssertEqual(items, decoded)
    }

    // MARK: - Equatable

    func testEqualItemsAreEqual() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1000)
        let a = ClipItem(id: id, text: "same", timestamp: date)
        let b = ClipItem(id: id, text: "same", timestamp: date)
        XCTAssertEqual(a, b)
    }

    func testDifferentTextNotEqual() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1000)
        let a = ClipItem(id: id, text: "one", timestamp: date)
        let b = ClipItem(id: id, text: "two", timestamp: date)
        XCTAssertNotEqual(a, b)
    }

    func testDifferentIdNotEqual() {
        let date = Date(timeIntervalSince1970: 1000)
        let a = ClipItem(id: UUID(), text: "same", timestamp: date)
        let b = ClipItem(id: UUID(), text: "same", timestamp: date)
        XCTAssertNotEqual(a, b)
    }
}
