//
//  DynamicRateLimitMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicRateLimitMiddleware
public final class DynamicRateLimitMiddleware: RateLimitMiddlewareProtocol, DynamicMiddlewareProtocol, @unchecked Sendable { // TODO: finish (need a way to identify requests, preferably by IP address or persistent UUID)
    private var limits:[String:Int]

    public init() {
        limits = [:]
    }

    @inlinable
    public func load() {
    }

    @inlinable
    public func handle(request: inout any RequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        return true
    }

    public var debugDescription: String {
        "DynamicRateLimitMiddleware()" // TODO: finish
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicRateLimitMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}
#endif