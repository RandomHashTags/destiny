
import Destiny
import Testing

#if Logging
import Logging
#endif

@Suite
struct HTTPDateFormatTests {
    @Test
    func httpDateFormatLiteral() {
        var value = HTTPDateFormat.get(year: 2025, month: 3, day: 18, dayOfWeek: 5, hour: 22, minute: 13, second: 0)
        #expect(value.unsafeString() == "Fri, 18 Apr 2025 22:13:00 GMT")

        var expected = "Sun, 01 Jan 1 01:01:01 GMT"
        expected.append(Character(UnicodeScalar(0)))
        expected.append(Character(UnicodeScalar(0)))
        expected.append(Character(UnicodeScalar(0)))

        value = HTTPDateFormat.get(year: 1, month: 0, day: 1, dayOfWeek: 0, hour: 1, minute: 1, second: 1)
        #expect(value.unsafeString() == expected)

        expected = "Sat, 32 Dec 69 10:59:30 GMT"
        expected.append(Character(UnicodeScalar(0)))
        expected.append(Character(UnicodeScalar(0)))
        value = HTTPDateFormat.get(year: 69, month: 11, day: 32, dayOfWeek: 6, hour: 10, minute: 59, second: 30)
        #expect(value.unsafeString() == expected)
    }

    #if NonEmbedded
    @Test(.timeLimit(.minutes(1)))
    func httpDateFormat() async throws {
        #if Logging
        HTTPDateFormat.load(logger: Logger(label: "destiny.httpdateformat"))
        #else
        HTTPDateFormat.load()
        #endif

        try await Task.sleep(for: .seconds(1)) // wait to make sure `HTTPDateFormat` has loaded at least once
        var seconds = 5
        while true {
            try #require(HTTPDateFormat.count >= 26)
            try #require(!HTTPDateFormat.nowString.contains(Character(UnicodeScalar(0))))
            seconds -= 1
            guard seconds > 0 else { return }
            try await Task.sleep(for: .seconds(1))
        }
    }
    #endif
}