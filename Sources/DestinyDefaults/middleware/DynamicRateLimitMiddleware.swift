//
//  DynamicRateLimitMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicRateLimitMiddleware
public final class DynamicRateLimitMiddleware : RateLimitMiddlewareProtocol, DynamicMiddlewareProtocol, @unchecked Sendable { // TODO: finish (need a way to identify requests, preferably by IP address)
    private var limits:[String:Int]

    public init() {
        limits = [:]
    }

    @inlinable
    public func load() {
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool {
        return true
    }

    public var debugDescription : String {
        "DynamicRateLimitMiddleware()" // TODO: finish
    }
}

// MARK: Parse
public extension DynamicRateLimitMiddleware {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}