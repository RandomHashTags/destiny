
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
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

import Logging

// MARK: HTTPDateFormat
/// Default storage that optimally keeps track of the current date in the HTTP Format,
/// as defined by the [spec](https://www.rfc-editor.org/rfc/rfc2616#section-3.3).
public struct HTTPDateFormat: Sendable {
    public static var shared = HTTPDateFormat()
    @inlinable public static var placeholder: String { "Thu, 01 Jan 1970 00:00:00 GMT" }

    public typealias InlineArrayResult = InlineArray<29, UInt8>

    public var nowInlineArray:InlineArrayResult = #inlineArray("Thu, 01 Jan 1970 00:00:00 GMT")

    /// Begins the auto-updating of the current date in the HTTP Format.
    @inlinable
    public mutating func load(logger: Logger) async throws {
        // TODO: make it update at the beginning of the second
        while !Task.isCancelled {
            //let clock:SuspendingClock = SuspendingClock()
            //var now:SuspendingClock.Instant = clock.now
            do {
                //var updateAt:SuspendingClock.Instant = now
                //updateAt.duration(to: Duration.init(secondsComponent: 1, attosecondsComponent: 0))
                //try await Task.sleep(until: updateAt, tolerance: Duration.seconds(1), clock: clock)
                try await Task.sleep(for: .seconds(1))
                self.now()
            } catch {
                logger.warning(Logger.Message(stringLiteral: "[HTTPDateFormat] Encountered error trying to sleep task: \(error)"))
            }
        }
    }

    /// Mutates `self` assigning `nowInlineArray` to the HTTP formatted result representing the time it was executed.
    /// - Returns: The HTTP formatted result, at the time it was executed, as an `InlineArrayResult`.
    @discardableResult
    @inlinable
    public mutating func now() -> InlineArrayResult? {
        let result:InlineArrayResult?
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        result = nowGlibc()
        #else
        result = nil
        #endif
        if let result {
            nowInlineArray = result
        }
        return result
    }
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
    @inlinable
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
        value[0] = dayName[0]
        value[1] = dayName[1]
        value[2] = dayName[2]
        value[3] = .comma
        value[4] = .space
        value[5] = dayNumbers[0]
        value[6] = dayNumbers[1]
        value[7] = .space
        value[8] = monthName[0]
        value[9] = monthName[1]
        value[10] = monthName[2]
        value[11] = .space
        value[12] = yearNumbers[0]
        var index = 13
        if yearNumbers[1] != 0 {
            value[index] = yearNumbers[1]
            index += 1
        }
        if yearNumbers[2] != 0 {
            value[index] = yearNumbers[2]
            index += 1
        }
        if yearNumbers[3] != 0 {
            value[index] = yearNumbers[3]
            index += 1
        }
        value[index] = .space
        index += 1
        value[index] = hourNumbers[0]
        index += 1
        value[index] = hourNumbers[1]
        index += 1
        value[index] = .colon
        index += 1
        value[index] = minuteNumbers[0]
        index += 1
        value[index] = minuteNumbers[1]
        index += 1
        value[index] = .colon
        index += 1
        value[index] = secondNumbers[0]
        index += 1
        value[index] = secondNumbers[1]
        index += 1
        value[index] = .space
        index += 1
        value[index] = .G
        index += 1
        value[index] = .M
        index += 1
        value[index] = .T
        return value
    }
    @inlinable
    static func httpDayName<T: BinaryInteger>(_ int: T) -> InlineArray<3, UInt8> {
        switch int {
        case 0:  return #inlineArray("Sun")
        case 1:  return #inlineArray("Mon")
        case 2:  return #inlineArray("Tue")
        case 3:  return #inlineArray("Wed")
        case 4:  return #inlineArray("Thu")
        case 5:  return #inlineArray("Fri")
        case 6:  return #inlineArray("Sat")
        default: return #inlineArray("???")
        }
    }
    @inlinable
    static func httpMonthName<T: BinaryInteger>(_ int: T) -> InlineArray<3, UInt8> {
        switch int {
        case 0:  return #inlineArray("Jan")
        case 1:  return #inlineArray("Feb")
        case 2:  return #inlineArray("Mar")
        case 3:  return #inlineArray("Apr")
        case 4:  return #inlineArray("May")
        case 5:  return #inlineArray("Jun")
        case 6:  return #inlineArray("Jul")
        case 7:  return #inlineArray("Aug")
        case 8:  return #inlineArray("Sep")
        case 9:  return #inlineArray("Oct")
        case 10: return #inlineArray("Nov")
        case 11: return #inlineArray("Dec")
        default: return #inlineArray("???")
        }
    }
    @inlinable
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

    @inlinable
    static func httpNumber<let count: Int, T: BinaryInteger>(_ int: T) -> InlineArray<count, UInt8> {
        var value = InlineArray<count, UInt8>(repeating: 0)
        var i = 0
        for char in String(int) {
            if i < count, let v = char.asciiValue {
                value[i] = v
                i += 1
            }
        }
        return value
    }
}

#if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
// MARK: Glibc
extension HTTPDateFormat {
    // https://linux.die.net/man/3/localtime
    @inlinable
    public func nowGlibc() -> InlineArrayResult? {
        var now = time(nil)
        guard let gmt = gmtime(&now) else { return nil }
        return httpDateGlibc(gmt.pointee)
    }
    @inlinable
    func httpDateGlibc(_ gmt: tm) -> InlineArrayResult {
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

#if canImport(FoundationEssentials) || canImport(Foundation)

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// MARK: Foundation
extension HTTPDateFormat {
    @inlinable
    public static func get(date: Date) -> InlineArrayResult {
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: date)
        let values = (
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0,
            components.weekday ?? 0,
            components.hour ?? 0,
            components.minute ?? 0,
            components.second ?? 0
        )
        return get(
            year: values.0,
            month: UInt8(values.1) - 1,
            day: UInt8(values.2),
            dayOfWeek: UInt8(values.3) - 1,
            hour: UInt8(values.4),
            minute: UInt8(values.5),
            second: UInt8(values.6)
        )
    }
}

#endif