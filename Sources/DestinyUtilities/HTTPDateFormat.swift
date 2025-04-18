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
    public static func now() -> String? {
        #if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
        return nowGlibc()
        #else
        return nil
        #endif
    }

    /// - Returns: A string that represents a date and time in the HTTP preferred format, as defined by the [spec](https://www.rfc-editor.org/rfc/rfc2616#section-3.3).
    @inlinable
    public static func get<T: BinaryInteger>(year: T, month: T, day: T, dayOfWeek: T, hour: T, minute: T, second: T) -> String {
        return httpDayName(dayOfWeek) + ", "
            + httpDateNumber(day) + " "
            + httpMonthName(month) + " "
            + String(year) + " "
            + httpDateNumber(hour) + ":" + httpDateNumber(minute) + ":" + httpDateNumber(second)
            + " GMT"
    }
    @inlinable
    static func httpDayName<T: BinaryInteger>(_ int: T) -> String {
        switch int {
        case 0:  return "Sun"
        case 1:  return "Mon"
        case 2:  return "Tue"
        case 3:  return "Wed"
        case 4:  return "Thu"
        case 5:  return "Fri"
        default: return "Sat"
        }
    }
    @inlinable
    static func httpMonthName<T: BinaryInteger>(_ int: T) -> String {
        switch int {
        case 0:  return "Jan"
        case 1:  return "Feb"
        case 2:  return "Mar"
        case 3:  return "Apr"
        case 4:  return "May"
        case 5:  return "Jun"
        case 6:  return "Jul"
        case 7:  return "Aug"
        case 8:  return "Sep"
        case 9:  return "Oct"
        case 10: return "Nov"
        default: return "Dec"
        }
    }
    @inlinable
    static func httpDateNumber<T: BinaryInteger>(_ int: T) -> String {
        if int < 10 {
            return "0" + String(int)
        } else {
            return String(int)
        }
    }
}

#if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
// MARK: Glibc
extension HTTPDateFormat {
    @inlinable
    public static func nowGlibc() -> String? {
        var now = time(nil)
        guard let gmt = gmtime(&now) else { return nil }
        return httpDateGlibc(gmt.pointee)
    }
    @inlinable
    static func httpDateGlibc(_ gmt: tm) -> String {
        return HTTPDateFormat.get(year: 1900 + gmt.tm_year, month: gmt.tm_mon, day: gmt.tm_mday, dayOfWeek: gmt.tm_wday, hour: gmt.tm_hour, minute: gmt.tm_min, second: gmt.tm_sec)
    }
}
#endif

#if canImport(FoundationEssentials) || canImport(Foundation)
// MARK: Foundation
extension HTTPDateFormat {
    @inlinable
    public static func get(date: Date) -> String {
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