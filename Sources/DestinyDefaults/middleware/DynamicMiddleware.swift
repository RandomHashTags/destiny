//
//  DynamicMiddleware.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicMiddleware
/// Default Dynamic Middleware which handles requests to dynamic routes.
public struct DynamicMiddleware : DynamicMiddlewareProtocol {
    public static let defaultOnError:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void = { request, response, error in
        response.status = .internalServerError
        response.headers[HTTPResponseHeader.contentTypeRawName] = HTTPMediaTypes.Application.json.httpValue
        response.result = .string("{\"error\":true,\"reason\":\"\(error)\"}")
    }

    public let handleLogic:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    private var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) {
        self.handleLogic = handleLogic
    }

    @inlinable
    public mutating func load() {
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool {
        try await handleLogic(&request, &response)
        return true
    }

    public var debugDescription : String {
        return "DynamicMiddleware \(logic)"
    }
}

// MARK: Parse
public extension DynamicMiddleware {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var logic:String = "\(function.trailingClosure?.debugDescription ?? "{ _, _ in }")"
        for argument in function.arguments {
            if let _:String = argument.label?.text {
            } else {
                logic = "\(argument.expression)"
            }
        }
        var middleware:DynamicMiddleware = DynamicMiddleware { _, _ in }
        middleware.logic = "\(logic)"
        return middleware
    }
}