//
//  DynamicMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

/// The core `MiddlewareProtocol` that powers Destiny's dynamic middleware which handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
    /// Whether or not this middleware handles a request asynchronously or synchronously.
    var isAsync : Bool { get }
    
    /// Whether or not this middleware should handle a request.
    @inlinable func shouldHandle(request: inout Request, response: borrowing DynamicResponseProtocol) -> Bool

    @inlinable func handle(request: inout Request, response: inout DynamicResponseProtocol) throws
    @inlinable func handleAsync(request: inout Request, response: inout DynamicResponseProtocol) async throws

    @inlinable func onError(request: inout Request, response: inout DynamicResponseProtocol, error: Error)
    @inlinable func onErrorAsync(request: inout Request, response: inout DynamicResponseProtocol, error: Error) async
}