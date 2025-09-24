
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#else
#warning("HTTPDateFormat is currently not supported for your platform; request support at https://github.com/RandomHashTags/destiny/discussions/new?category=request-feature")
// TODO: support
#endif

#if Logging
import Logging
#endif

// MARK: HTTPDateFormat
/// Default storage that optimally keeps track of the current date in the HTTP Format,
/// as defined by the [spec](https://www.rfc-editor.org/rfc/rfc2616#section-3.3).
public struct HTTPDateFormat: Sendable {
    #if Inlinable
    @inlinable
    #endif
    public static var placeholder: String {
        "Thu, 01 Jan 1970 00:00:00 GMT"
    }

    public typealias InlineArrayResult = InlineArray<29, UInt8>

    @usableFromInline
    nonisolated(unsafe) static var _nowInlineArray: InlineArrayResult = [
        84, 104, 117, 44, 32, 48, 49, 32, 74, 97, 110, 32, 49, 57, 55, 48, 32, 48, 48, 58, 48, 48, 58, 48, 48, 32, 71, 77, 84
    ] // Thu, 01 Jan 1970 00:00:00 GMT

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public static var nowInlineArray: InlineArrayResult {
        _read { yield _nowInlineArray }
    }

    /// - Returns: HTTP formatted result, at the time it was executed, as an `InlineArrayResult`.
    @discardableResult
    #if Inlinable
    @inlinable
    #endif
    public static func now() -> InlineArrayResult? {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return nowGlibc()
        #else
        return nil
        #endif
    }
}

// MARK: Load
extension HTTPDateFormat {
    /// Begins the auto-updating of the current date in the HTTP Format.
    #if Logging
    #if Inlinable
    @inlinable
    #endif
    public static func load(logger: Logger) {
        // TODO: make it update at the beginning of the second
        Task.detached(priority: .userInitiated) {
            while !Task.isCancelled {
                //let clock:SuspendingClock = SuspendingClock()
                //var now:SuspendingClock.Instant = clock.now
                do { // TODO: fix
                    //var updateAt:SuspendingClock.Instant = now
                    //updateAt.duration(to: Duration.init(secondsComponent: 1, attosecondsComponent: 0))
                    //try await Task.sleep(until: updateAt, tolerance: Duration.seconds(1), clock: clock)
                    try await Task.sleep(for: .seconds(1))
                    if let result = Self.now() {
                        _nowInlineArray = result
                    }
                } catch {
                    logger.warning("[HTTPDateFormat] Encountered error trying to sleep task: \(error)")
                }
            }
        }
    }
    #else
    #if Inlinable
    @inlinable
    #endif
    public static func load() {
        // TODO: make it update at the beginning of the second
        Task.detached(priority: .userInitiated) {
            while !Task.isCancelled {
                //let clock:SuspendingClock = SuspendingClock()
                //var now:SuspendingClock.Instant = clock.now
                do { // TODO: fix
                    //var updateAt:SuspendingClock.Instant = now
                    //updateAt.duration(to: Duration.init(secondsComponent: 1, attosecondsComponent: 0))
                    //try await Task.sleep(until: updateAt, tolerance: Duration.seconds(1), clock: clock)
                    try await Task.sleep(for: .seconds(1))
                    if let result = Self.now() {
                        _nowInlineArray = result
                    }
                } catch {
                    //logger.warning("[HTTPDateFormat] Encountered error trying to sleep task: \(error)")
                }
            }
        }
    }
    #endif
}

// MARK: Get
extension HTTPDateFormat {
    /// - Parameters:
    ///   - year: Target year.
    ///   - month: Number of months since January, in the range 0 to 11.
    ///   - day: Day of the month, in the range 1 to 31.
    ///   - dayOfWeek: Number of days since Sunday, in the range 0 to 6.
    ///   - hour: Number of hours past midnight (00:00), in the range 0 to 23.
    ///   - minute: Number of minutes after the hour, in the range 0 to 59.
    ///   - second: Number of seconds after the minute, normally in the range 0 to 59, but can be up to 60 to allow for leap seconds.
    /// - Returns: A string that represents a date and time in the HTTP preferred format, as defined by the [spec](https://www.rfc-editor.org/rfc/rfc2616#section-3.3).
    #if Inlinable
    @inlinable
    #endif
    public static func get(
        year: Int,
        month: UInt8,
        day: UInt8,
        dayOfWeek: UInt8,
        hour: UInt8,
        minute: UInt8,
        second: UInt8
    ) -> InlineArrayResult {
        let dayName = httpDayName(dayOfWeek)
        let dayNumbers = httpDateNumber(day)
        let monthName = httpMonthName(month)
        let yearNumbers:InlineArray<4, UInt8> = httpNumber(year)
        let hourNumbers = httpDateNumber(hour)
        let minuteNumbers = httpDateNumber(minute)
        let secondNumbers = httpDateNumber(second)

        var value = InlineArrayResult(repeating: 0)
        value[unchecked: 0] = dayName[unchecked: 0]
        value[unchecked: 1] = dayName[unchecked: 1]
        value[unchecked: 2] = dayName[unchecked: 2]
        value[unchecked: 3] = .comma
        value[unchecked: 4] = .space
        value[unchecked: 5] = dayNumbers[unchecked: 0]
        value[unchecked: 6] = dayNumbers[unchecked: 1]
        value[unchecked: 7] = .space
        value[unchecked: 8] = monthName[unchecked: 0]
        value[unchecked: 9] = monthName[unchecked: 1]
        value[unchecked: 10] = monthName[unchecked: 2]
        value[unchecked: 11] = .space
        value[unchecked: 12] = yearNumbers[unchecked: 0]
        var index = 13
        if yearNumbers[1] != 0 {
            value[unchecked: index] = yearNumbers[unchecked: 1]
            index += 1
        }
        if yearNumbers[2] != 0 {
            value[unchecked: index] = yearNumbers[unchecked: 2]
            index += 1
        }
        if yearNumbers[3] != 0 {
            value[unchecked: index] = yearNumbers[unchecked: 3]
            index += 1
        }
        value[unchecked: index] = .space
        index += 1
        value[unchecked: index] = hourNumbers[unchecked: 0]
        index += 1
        value[unchecked: index] = hourNumbers[unchecked: 1]
        index += 1
        value[unchecked: index] = .colon
        index += 1
        value[unchecked: index] = minuteNumbers[unchecked: 0]
        index += 1
        value[unchecked: index] = minuteNumbers[unchecked: 1]
        index += 1
        value[unchecked: index] = .colon
        index += 1
        value[unchecked: index] = secondNumbers[unchecked: 0]
        index += 1
        value[unchecked: index] = secondNumbers[unchecked: 1]
        index += 1
        value[unchecked: index] = .space
        index += 1
        value[unchecked: index] = .G
        index += 1
        value[unchecked: index] = .M
        index += 1
        value[unchecked: index] = .T
        return value
    }

    #if Inlinable
    @inlinable
    #endif
    static func httpDayName(_ int: some BinaryInteger) -> InlineArray<3, UInt8> {
        switch int {
        case 0:  [83, 117, 110] // Sun
        case 1:  [77, 111, 110] // Mon
        case 2:  [84, 117, 101] // Tue
        case 3:  [87, 101, 100] // Wed
        case 4:  [84, 104, 117] // Thu
        case 5:  [70, 114, 105] // Fri
        case 6:  [83, 97, 116]  // Sat
        default: [63, 63, 63]   // ???
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func httpMonthName(_ int: some BinaryInteger) -> InlineArray<3, UInt8> {
        switch int {
        case 0:  [74, 97, 110]  // Jan
        case 1:  [70, 101, 98]  // Feb
        case 2:  [77, 97, 114]  // Mar
        case 3:  [65, 112, 114] // Apr
        case 4:  [77, 97, 121]  // May
        case 5:  [74, 117, 110] // Jun
        case 6:  [74, 117, 108] // Jul
        case 7:  [65, 117, 103] // Aug
        case 8:  [83, 101, 112] // Sep
        case 9:  [79, 99, 116]  // Oct
        case 10: [78, 111, 118] // Nov
        case 11: [68, 101, 99]  // Dec
        default: [63, 63, 63]   // ???
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func httpDateNumber(_ int: UInt8) -> InlineArray<2, UInt8> {
        // we don't use a switch here because it would bloat the binary
        if int < 10 {
            return [48, 48 + UInt8(int)]
        } else if int < 20 {
            return [49, 38 + UInt8(int)]
        } else if int < 30 {
            return [50, 28 + UInt8(int)]
        } else if int < 40 {
            return [51, 18 + UInt8(int)]
        } else {
            return httpNumber(int) // future proofing
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func httpNumber<let count: Int>(_ int: some BinaryInteger) -> InlineArray<count, UInt8> {
        var value = InlineArray<count, UInt8>(repeating: 0)
        var i = 0
        for char in String(int) {
            if i < count, let v = char.asciiValue {
                value[unchecked: i] = v
                i += 1
            }
        }
        return value
    }
}

#if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)

// MARK: SwiftGlibc
extension HTTPDateFormat {
    // https://linux.die.net/man/3/localtime
    #if Inlinable
    @inlinable
    #endif
    public static func nowGlibc() -> InlineArrayResult? {
        var now = time(nil)
        guard let gmt = gmtime(&now) else { return nil }
        return httpDateGlibc(gmt.pointee)
    }

    #if Inlinable
    @inlinable
    #endif
    static func httpDateGlibc(_ gmt: tm) -> InlineArrayResult {
        return HTTPDateFormat.get(
            year: 1900 + Int(gmt.tm_year),
            month: UInt8(gmt.tm_mon),
            day: UInt8(gmt.tm_mday),
            dayOfWeek: UInt8(gmt.tm_wday),
            hour: UInt8(gmt.tm_hour),
            minute: UInt8(gmt.tm_min),
            second: UInt8(gmt.tm_sec)
        )
    }
}

#endif