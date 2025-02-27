//
//  DynamicDateMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

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
        guard let string:String = HTTPDateFormat.now() else {
            Application.shared.logger.warning(Logger.Message(stringLiteral: "[DynamicDateMiddleware] Failed to update value"))
            return
        }
        _date = string
    }

    @inlinable
    public func handle(request: inout any RequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        response.headers["Date"] = _date
        return true
    }

    public var debugDescription : String {
        "DynamicDateMiddleware()"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicDateMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}
#endif