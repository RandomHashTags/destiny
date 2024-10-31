//
//  DynamicMiddleware.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import HTTPTypes
import SwiftSyntax

public struct DynamicMiddleware : DynamicMiddlewareProtocol {
    public let async:Bool
    public let shouldHandleLogic:@Sendable (_ request: borrowing Request) -> Bool
    public let handleLogic:(@Sendable (_ request: borrowing Request, _ response: inout DynamicResponse) throws -> Void)?
    public let handleLogicAsync:(@Sendable (_ request: borrowing Request, _ response: inout DynamicResponse) async throws -> Void)?

    fileprivate var logic:String = ""

    public init(
        async: Bool,
        shouldHandleLogic: @escaping @Sendable (_ request: borrowing Request) -> Bool,
        handleLogic: (@Sendable (_ request: borrowing Request, _ response: inout DynamicResponse) throws -> Void)?,
        handleLogicAsync: (@Sendable (_ request: borrowing Request, _ response: inout DynamicResponse) async throws -> Void)?
    ) {
        self.async = async
        self.shouldHandleLogic = shouldHandleLogic
        self.handleLogic = handleLogic
        self.handleLogicAsync = handleLogicAsync
    }

    public var isAsync: Bool { async }

    public func shouldHandle(request: borrowing Request) -> Bool { shouldHandleLogic(request) }

    public func handle(request: borrowing Request, response: inout DynamicResponse) throws {
        try handleLogic!(request, &response)
    }

    public func handleAsync(request: borrowing Request, response: inout DynamicResponse) async throws {
        try await handleLogicAsync!(request, &response)
    }

    public var description: String {
        return "DynamicMiddleware(\(logic))"
    }
}

public extension DynamicMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> DynamicMiddleware {
        var async:Bool = false
        var shouldHandleLogic:String = "false"
        var handleLogic:String = "nil"
        var handleLogicAsync:String = "nil"
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
                default:
                    break
            }
        }
        var middleware:DynamicMiddleware = DynamicMiddleware(async: async, shouldHandleLogic: {_ in false }, handleLogic: nil, handleLogicAsync: nil)
        middleware.logic = "async: \(async), shouldHandleLogic: \(shouldHandleLogic), handleLogic: \(handleLogic), handleLogicAsync: \(handleLogicAsync)"
        return middleware
    }
}