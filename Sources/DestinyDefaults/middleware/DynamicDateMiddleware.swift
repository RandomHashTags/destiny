//
//  DynamicDateMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import DestinyUtilities
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Adds the `Date` header to responses for dynamic routes.
public final class DynamicDateMiddleware : DynamicMiddlewareProtocol, @unchecked Sendable {

    @usableFromInline
    var _timer:Timer!

    @usableFromInline
    var _date:String

    public init() {
        _timer = nil
        _date = Date().formatted(.iso8601)
    }

    @inlinable
    public func load() {
        // TODO: make it update at the beginning of the second
        _timer = Timer(fire: .now, interval: 1, repeats: true) { _ in
            self._date = Date().formatted(.iso8601)
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