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
/// Default Dynamic Middleware implementation which handles requests to dynamic routes.
public struct DynamicMiddleware : DynamicMiddlewareProtocol {
    public typealias ConcreteRequest = Request
    public typealias ConcreteResponse = DynamicResponse

    public static let defaultOnError:@Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteResponse, _ error: any Error) async -> Void = { request, response, error in
        response.message.status = .internalServerError
        response.message.headers[HTTPResponseHeader.contentTypeRawName] = "\(HTTPMediaType.applicationJson)"
        response.message.result = .string("{\"error\":true,\"reason\":\"\(error)\"}")
    }

    public let handleLogic:@Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteResponse) async throws -> Void
    private var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteResponse) async throws -> Void
    ) {
        self.handleLogic = handleLogic
    }

    @inlinable
    public mutating func load() {
    }

    @inlinable
    public func handle(request: inout ConcreteRequest, response: inout ConcreteResponse) async throws -> Bool {
        try await handleLogic(&request, &response)
        return true
    }

    public var debugDescription : String {
        return "DynamicMiddleware \(logic)"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var logic:String = "\(function.trailingClosure?.debugDescription ?? "{ _, _ in }")"
        for argument in function.arguments {
            if let _:String = argument.label?.text {
            } else {
                logic = "\(argument.expression)"
            }
        }
        var middleware = DynamicMiddleware { _, _ in }
        middleware.logic = "\(logic)"
        return middleware
    }
}
#endif