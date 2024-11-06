//
//  DynamicMiddleware.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import HTTPTypes
import SwiftSyntax

/// The default Dynamic Middleware that powers Destiny's dynamic middleware which handles requests to dynamic routes.
public struct DynamicMiddleware : DynamicMiddlewareProtocol {
    public static let defaultOnError:@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol, _ error: Error) -> Void = { request, response, error in
        response.status = .internalServerError
        response.headers[HTTPField.Name.contentType.rawName] = HTTPField.ContentType.json.rawValue
        response.result = .string("{\"error\":true,\"reason\":\"\(error)\"}")
    }

    public let async:Bool
    public let shouldHandleLogic:@Sendable (_ request: borrowing Request, _ response: borrowing DynamicResponseProtocol) -> Bool
    public let handleLogic:(@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol) throws -> Void)?
    public let handleLogicAsync:(@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol) async throws -> Void)?
    public let onError:@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol, _ error: Error) -> Void
    public let onErrorAsync:@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void

    fileprivate var logic:String = ""

    public init(
        async: Bool,
        shouldHandleLogic: @escaping @Sendable (_ request: borrowing Request, _ response: borrowing DynamicResponseProtocol) -> Bool,
        handleLogic: (@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol) throws -> Void)?,
        handleLogicAsync: (@Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol) async throws -> Void)?,
        onError: @escaping @Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol, _ error: Error) -> Void = DynamicMiddleware.defaultOnError,
        onErrorAsync: @escaping @Sendable (_ request: borrowing Request, _ response: inout DynamicResponseProtocol, _ error: Error) async -> Void = DynamicMiddleware.defaultOnError
    ) {
        self.async = async
        self.shouldHandleLogic = shouldHandleLogic
        self.handleLogic = handleLogic
        self.handleLogicAsync = handleLogicAsync
        self.onError = onError
        self.onErrorAsync = onErrorAsync
    }

    public var isAsync: Bool { async }

    public func shouldHandle(request: borrowing Request, response: borrowing DynamicResponseProtocol) -> Bool { shouldHandleLogic(request, response) }

    public func handle(request: borrowing Request, response: inout DynamicResponseProtocol) throws {
        try handleLogic!(request, &response)
    }

    public func handleAsync(request: borrowing Request, response: inout DynamicResponseProtocol) async throws {
        try await handleLogicAsync!(request, &response)
    }

    public func onError(request: borrowing Request, response: inout DynamicResponseProtocol, error: Error) {
        onError(request, &response, error)
    }
    public func onErrorAsync(request: borrowing Request, response: inout DynamicResponseProtocol, error: any Error) async {
        await onErrorAsync(request, &response, error)
    }

    public var debugDescription : String {
        return "DynamicMiddleware(\(logic))"
    }
}

public extension DynamicMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> DynamicMiddleware {
        var async:Bool = false
        var shouldHandleLogic:String = "{ _, _ in false }"
        var handleLogic:String = "nil"
        var handleLogicAsync:String = "nil"
        var onError:String = "nil"
        var onErrorAsync:String = "nil"
        for argument in function.arguments {
            switch argument.label!.text {
                case "async":
                    async = argument.expression.booleanLiteral!.literal.text == "true"
                    break
                case "shouldHandleLogic":
                    shouldHandleLogic = "\(argument.expression)"
                    break
                case "handleLogic":
                    handleLogic = "\(argument.expression)"
                    break
                case "handleLogicAsync":
                    handleLogicAsync = "\(argument.expression)"
                    break
                case "onError":
                    onError = "\(argument.expression)"
                    break
                case "onErrorAsync":
                    onErrorAsync = "\(argument.expression)"
                    break
                default:
                    break
            }
        }
        var middleware:DynamicMiddleware = DynamicMiddleware(
            async: async,
            shouldHandleLogic: { _, _ in false },
            handleLogic: nil,
            handleLogicAsync: nil,
            onError: DynamicMiddleware.defaultOnError,
            onErrorAsync: DynamicMiddleware.defaultOnError
        )
        let default_on_error:String = "DynamicMiddleware.defaultOnError"
        if onError == "nil" {
            onError = default_on_error
        }
        if onErrorAsync == "nil" {
            onErrorAsync = default_on_error
        }
        middleware.logic = "async: \(async), shouldHandleLogic: \(shouldHandleLogic), handleLogic: \(handleLogic), handleLogicAsync: \(handleLogicAsync), onError: \(onError), onErrorAsync: \(onErrorAsync)"
        return middleware
    }
}