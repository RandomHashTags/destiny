//
//  DynamicDateMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Darwin)
import Darwin
#else
#warning("DynamicDateMiddleware currently not supported for your platform; request support at https://github.com/RandomHashTags/destiny/discussions/new?category=request-feature")
// TODO: support
#endif

import DestinyUtilities
import Logging
import ServiceLifecycle
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicDateMiddleware
/// Adds the `Date` header to responses for dynamic routes.
public final class DynamicDateMiddleware : DynamicMiddlewareProtocol, @unchecked Sendable {
    @usableFromInline
    var _timer:Task<Void, Never>!

    @usableFromInline
    var _date:String

    public init() {
        _timer = nil
        _date = ""
    }

    @inlinable
    public func load() {
        #if !(canImport(Glibc) || canImport(Musl) || canImport(Darwin))
        return;
        #endif
        update()
        // TODO: make it update at the beginning of the second
        _timer = Task.detached(priority: .userInitiated) {
            //let clock:SuspendingClock = SuspendingClock()
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                //var now:SuspendingClock.Instant = clock.now
                do {
                    //var updateAt:SuspendingClock.Instant = now
                    //updateAt.duration(to: Duration.init(secondsComponent: 1, attosecondsComponent: 0))
                    //try await Task.sleep(until: updateAt, tolerance: Duration.seconds(1), clock: clock)
                    try await Task.sleep(for: .seconds(1))
                    self.update()
                } catch {
                    Application.shared.logger.warning(Logger.Message(stringLiteral: "[DynamicDateMiddleware] Encountered error trying to sleep task: \(error)"))
                }
            }
        }
    }

    @usableFromInline
    func update() {
        #if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
        updateGlibc()
        #endif
    }

    @inlinable
    func httpDate<T: BinaryInteger>(year: T, month: T, day: T, dayOfWeek: T, hour: T, minute: T, second: T) -> String {
        return httpDayName(dayOfWeek) + ", "
            + httpDateNumber(day) + " "
            + httpMonthName(month) + " "
            + String(year) + " "
            + httpDateNumber(hour) + ":" + httpDateNumber(minute) + ":" + httpDateNumber(second)
            + " GMT"
    }
    @inlinable
    func httpDayName<T: BinaryInteger>(_ int: T) -> String {
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
    func httpMonthName<T: BinaryInteger>(_ int: T) -> String {
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
    func httpDateNumber<T: BinaryInteger>(_ int: T) -> String {
        if int < 10 {
            return "0" + String(int)
        } else {
            return String(int)
        }
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool {
        response.headers["Date"] = _date
        return true
    }

    public var debugDescription : String {
        "DynamicDateMiddleware()"
    }
}

// MARK: Parse
public extension DynamicDateMiddleware {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}

#if canImport(Glibc) || canImport(Musl) || canImport(Darwin)
// MARK: Glibc
extension DynamicDateMiddleware {
    @inlinable
    func updateGlibc() {
        var now:time_t = time(nil)
        guard let gmt:UnsafeMutablePointer<tm> = gmtime(&now) else {
            Application.shared.logger.warning(Logger.Message(stringLiteral: "[DynamicDateMiddleware] Failed to convert epoch time to GMT"))
            return
        }
        _date = httpDateGlibc(gmt.pointee)
    }
    @inlinable
    func httpDateGlibc(_ gmt: tm) -> String {
        return httpDate(year: 1900 + gmt.tm_year, month: gmt.tm_mon, day: gmt.tm_mday, dayOfWeek: gmt.tm_wday, hour: gmt.tm_hour, minute: gmt.tm_min, second: gmt.tm_sec)
    }
}
#endif