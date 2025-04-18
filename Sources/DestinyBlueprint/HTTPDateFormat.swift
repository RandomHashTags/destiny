//
//  HTTPDateFormat.swift
//
//
//  Created by Evan Anderson on 1/6/25.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Darwin)
import Darwin
#else
#warning("HTTPDateFormat is currently not supported for your platform; request support at https://github.com/RandomHashTags/destiny/discussions/new?category=request-feature")
// TODO: support
#endif

// MARK: HTTPDateFormat
public enum HTTPDateFormat {
    @inlinable
    public static func now() -> InlineArray<29, UInt8>? {
        #if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
        return nowGlibc()
        #else
        return nil
        #endif
    }

    /// - Returns: A string that represents a date and time in the HTTP preferred format, as defined by the [spec](https://www.rfc-editor.org/rfc/rfc2616#section-3.3).
    @inlinable
    public static func get<T: BinaryInteger>(year: T, month: T, day: T, dayOfWeek: T, hour: T, minute: T, second: T) -> InlineArray<29, UInt8> {
        let space:UInt8 = 32
        let dayName = httpDayName(dayOfWeek)
        let dayNumbers = httpDateNumber(day)
        let monthName = httpMonthName(month)
        // year
        let hourNumbers = httpDateNumber(hour)
        let minuteNumbers = httpDateNumber(minute)
        let secondNumbers = httpDateNumber(second)

        var value:InlineArray<29, UInt8> = .init(repeating: 0)
        value[0] = dayName[0]
        value[1] = dayName[1]
        value[2] = dayName[2]
        value[3] = 44 // ,
        value[4] = space
        value[5] = dayNumbers[0]
        value[6] = dayNumbers[1]
        value[7] = space
        value[8] = monthName[0]
        value[9] = monthName[1]
        value[10] = monthName[2]
        value[11] = space
        value[12] = 48 // first year number
        value[13] = 48 // second year number
        value[14] = 48 // third year number
        value[15] = 48 // fourth year number
        value[16] = space
        value[17] = hourNumbers[0]
        value[18] = hourNumbers[1]
        value[19] = 58 // :
        value[20] = minuteNumbers[0]
        value[21] = minuteNumbers[1]
        value[22] = 58 // :
        value[23] = secondNumbers[0]
        value[24] = secondNumbers[1]
        value[25] = space
        value[26] = 71 // G
        value[27] = 77 // M
        value[28] = 84 // T
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
        default: return #inlineArray("Sat")
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
        default: return #inlineArray("Dec")
        }
    }
    @inlinable
    static func httpDateNumber<T: BinaryInteger>(_ int: T) -> InlineArray<2, UInt8> {
        if int < 10 {
            return [48, 48 + UInt8(int)]
        } else {
            switch int {
            case 10: return #inlineArray("10")
            case 11: return #inlineArray("11")
            case 12: return #inlineArray("12")
            case 13: return #inlineArray("13")
            case 14: return #inlineArray("14")
            case 15: return #inlineArray("15")
            case 16: return #inlineArray("16")
            case 17: return #inlineArray("17")
            case 18: return #inlineArray("18")
            case 19: return #inlineArray("19")
            case 20: return #inlineArray("20")
            default: return [0, 0]
            }
        }
    }
}

#if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
// MARK: Glibc
extension HTTPDateFormat {
    @inlinable
    public static func nowGlibc() -> InlineArray<29, UInt8>? {
        var now = time(nil)
        guard let gmt = gmtime(&now) else { return nil }
        return httpDateGlibc(gmt.pointee)
    }
    @inlinable
    static func httpDateGlibc(_ gmt: tm) -> InlineArray<29, UInt8> {
        return HTTPDateFormat.get(year: 1900 + gmt.tm_year, month: gmt.tm_mon, day: gmt.tm_mday, dayOfWeek: gmt.tm_wday, hour: gmt.tm_hour, minute: gmt.tm_min, second: gmt.tm_sec)
    }
}
#endif

#if canImport(FoundationEssentials) || canImport(Foundation)
// MARK: Foundation
extension HTTPDateFormat {
    @inlinable
    public static func get(date: Date) -> InlineArray<29, UInt8> {
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
        return get(year: values.0, month: values.1, day: values.2, dayOfWeek: values.3, hour: values.4, minute: values.5, second: values.6)
    }
}

#endif