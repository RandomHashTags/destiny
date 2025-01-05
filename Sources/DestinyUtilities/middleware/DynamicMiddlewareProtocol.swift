//
//  DynamicMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

/// Core Dynamic Middleware protocol which handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
    /// Load logic when the middleware is ready to process requests.
    @inlinable mutating func load()

    /// The handler.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    ///   - response: The current response for the request.
    /// - Returns: Whether or not to continue processing the request.
    @inlinable func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool
}