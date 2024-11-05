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
    /// Parsing logic for this middleware. Computed at compile time.
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this middleware at compile time.
    static func parse(_ function: FunctionCallExprSyntax) -> Self
}

// MARK: DynamicMiddlewareProtocol
/// The core `MiddlewareProtocol` that powers Destiny's dynamic middleware which handles requests to dynamic routes.
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
/// The core `MiddlewareProtocol` that powers Destiny's static middleware which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    /// What route request methods this middleware handles.
    /// - Warning: `nil` makes it handle all methods.
    var handlesMethods : Set<HTTPRequest.Method>? { get }
    /// What route response statuses this middleware handles.
    /// - Warning: `nil` makes it handle all statuses.
    var handlesStatuses : Set<HTTPResponse.Status>? { get }
    /// What route content types this middleware handles.
    /// - Warning: `nil` makes it handle all content types.
    var handlesContentTypes : Set<HTTPField.ContentType>? { get }

    /// What response status this middleware applies to routes.
    var appliesStatus : HTTPResponse.Status? { get }
    /// What content type this middleware applies to routes.
    var appliesContentType : HTTPField.ContentType? { get }
    /// What response headers this middleware applies to routes.
    var appliesHeaders : [String:String] { get }
}
public extension StaticMiddlewareProtocol {
    @inlinable
    func handles(method: HTTPRequest.Method, contentType: HTTPField.ContentType, status: HTTPResponse.Status) -> Bool {
        return (handlesMethods == nil || handlesMethods!.contains(method))
            && (handlesContentTypes == nil || handlesContentTypes!.contains(contentType))
            && (handlesStatuses == nil || handlesStatuses!.contains(status))
    }
}