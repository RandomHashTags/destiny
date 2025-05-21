
import Destiny
import FoundationEssentials
import SwiftCompression
import Testing

struct HTTPDateFormatTests {
    @Test
    func httpDateFormat() {
        var value = HTTPDateFormat.get(year: 2025, month: 4, day: 18, dayOfWeek: 6, hour: 22, minute: 13, second: 0)
        #expect(value.string() == "Fri, 18 Apr 2025 22:13:00 GMT")

        value = HTTPDateFormat.get(year: 1, month: 1, day: 1, dayOfWeek: 1, hour: 1, minute: 1, second: 1)
        #expect(value.string() == "Sun, 01 Jan 1 01:01:01 GMT")

        value = HTTPDateFormat.get(year: 69, month: 12, day: 32, dayOfWeek: 7, hour: 10, minute: 59, second: 30)
        #expect(value.string() == "Sat, 32 Dec 69 10:59:30 GMT")

        value = HTTPDateFormat.get(date: Date(timeIntervalSince1970: 0))
        #expect(value.string() == "Wed, 31 Dec 1969 18:00:00 GMT")

        value = HTTPDateFormat.get(date: Date(timeIntervalSince1970: 1745033167))
        #expect(value.string() == "Fri, 18 Apr 2025 22:26:07 GMT")
    }
}