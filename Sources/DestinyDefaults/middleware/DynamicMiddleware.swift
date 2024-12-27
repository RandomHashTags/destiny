//
//  DynamicMiddleware.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax

/// The default Dynamic Middleware that powers Destiny's dynamic middleware which handles requests to dynamic routes.
public struct DynamicMiddleware : DynamicMiddlewareProtocol {
    public static let defaultOnError:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void = { request, response, error in
        response.status = .internalServerError
        response.headers[HTTPField.Name.contentType.rawName] = HTTPMediaType.Application.json.rawValue
        response.result = .string("{\"error\":true,\"reason\":\"\(error)\"}")
    }

    public let shouldHandleLogic:@Sendable (_ request: inout RequestProtocol, _ response: borrowing DynamicResponseProtocol) -> Bool
    public let handleLogic:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    public let onError:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void

    fileprivate var logic:String = ""

    public init(
        shouldHandleLogic: @escaping @Sendable (_ request: inout RequestProtocol, _ response: borrowing DynamicResponseProtocol) -> Bool,
        handleLogic: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void,
        onError: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void = DynamicMiddleware.defaultOnError
    ) {
        self.shouldHandleLogic = shouldHandleLogic
        self.handleLogic = handleLogic
        self.onError = onError
    }

    @inlinable
    public func shouldHandle(request: inout RequestProtocol, response: borrowing DynamicResponseProtocol) -> Bool {
        shouldHandleLogic(&request, response)
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws {
        try await handleLogic(&request, &response)
    }

    @inlinable
    public func onError(request: inout RequestProtocol, response: inout DynamicResponseProtocol, error: Error) async {
        await onError(&request, &response, error)
    }

    public var debugDescription : String {
        return "DynamicMiddleware(\n\(logic)\n)"
    }
}

public extension DynamicMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> Self {
        var shouldHandleLogic:String = "{ _, _ in false }"
        var handleLogic:String = "{ _, _ in }"
        var onError:String = "nil"
        for argument in function.arguments {
            switch argument.label!.text {
            case "shouldHandleLogic":
                shouldHandleLogic = "\(argument.expression)"
                break
            case "handleLogic":
                handleLogic = "\(argument.expression)"
                break
            case "onError":
                onError = "\(argument.expression)"
                break
            default:
                break
            }
        }
        var middleware:DynamicMiddleware = DynamicMiddleware(
            shouldHandleLogic: { _, _ in false },
            handleLogic: { _, _ in },
            onError: DynamicMiddleware.defaultOnError
        )
        let default_on_error:String = "DynamicMiddleware.defaultOnError"
        if onError == "nil" {
            onError = default_on_error
        }
        middleware.logic = "shouldHandleLogic: \(shouldHandleLogic),\nhandleLogic: \(handleLogic),\nonError: \(onError)"
        return middleware
    }
}