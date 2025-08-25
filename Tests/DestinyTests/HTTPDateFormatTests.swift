
import Destiny
import Testing

@Suite
struct HTTPDateFormatTests {
    @Test
    func httpDateFormat() {
        var value = HTTPDateFormat.get(year: 2025, month: 3, day: 18, dayOfWeek: 5, hour: 22, minute: 13, second: 0)
        #expect(value.string() == "Fri, 18 Apr 2025 22:13:00 GMT")

        value = HTTPDateFormat.get(year: 1, month: 0, day: 1, dayOfWeek: 0, hour: 1, minute: 1, second: 1)
        #expect(value.string() == "Sun, 01 Jan 1 01:01:01 GMT")

        value = HTTPDateFormat.get(year: 69, month: 11, day: 32, dayOfWeek: 6, hour: 10, minute: 59, second: 30)
        #expect(value.string() == "Sat, 32 Dec 69 10:59:30 GMT")
    }
}