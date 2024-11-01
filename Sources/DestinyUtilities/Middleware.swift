//
//  Middleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes
import SwiftSyntax

// MARK: MiddlewareProtocol
/// The core Middleware protocol that powers Destiny's Middleware.
public protocol MiddlewareProtocol : Sendable {
    static func parse(_ function: FunctionCallExprSyntax) -> Self
}

// MARK: DynamicMiddlewareProtocol
/// A `MiddlewareProtocol` that handles requests dynamically.
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol, CustomStringConvertible {
    /// Whether or not this middleware handles a request asynchronously or synchronously.
    var isAsync : Bool { get }
    
    /// Whether or not this middleware should handle a request.
    @inlinable func shouldHandle(request: borrowing Request, response: borrowing DynamicResponse) -> Bool

    @inlinable func handle(request: borrowing Request, response: inout DynamicResponse) throws
    @inlinable func handleAsync(request: borrowing Request, response: inout DynamicResponse) async throws

    @inlinable func onError(request: borrowing Request, response: inout DynamicResponse, error: Error)
    @inlinable func onErrorAsync(request: borrowing Request, response: inout DynamicResponse, error: Error) async
}

// MARK: StaticMiddlewareProtocol
/// A `MiddlewareProtocol` that handles routes only at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    var appliesToMethods : Set<HTTPRequest.Method> { get }
    var appliesToStatuses : Set<HTTPResponse.Status> { get }
    var appliesToContentTypes : Set<HTTPField.ContentType> { get }

    var appliesStatus : HTTPResponse.Status? { get }
    var appliesHeaders : [String:String] { get }
}