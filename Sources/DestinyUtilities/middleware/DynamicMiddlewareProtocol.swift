//
//  DynamicMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

/// The core Dynamic Middleware protocol which handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
    /// The handler.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    ///   - response: The current response for the request.
    @inlinable func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws
}