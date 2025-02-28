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
public final class DynamicRateLimitMiddleware : RateLimitMiddlewareProtocol, DynamicMiddlewareProtocol, @unchecked Sendable { // TODO: finish (need a way to identify requests, preferably by IP address or persistent UUID)
    public typealias ConcreteRequest = Request

    private var limits:[String:Int]

    public init() {
        limits = [:]
    }

    @inlinable
    public func load() {
    }

    @inlinable
    public func handle(request: inout ConcreteRequest, response: inout any DynamicResponseProtocol) async throws -> Bool {
        return true
    }

    public var debugDescription : String {
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