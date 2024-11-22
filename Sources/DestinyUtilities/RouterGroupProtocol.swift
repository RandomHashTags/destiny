//
//  RouterGroupProtocol.swift
//
//
//  Created by Evan Anderson on 11/22/24.
//

/// The core Router Group protocol that powers how Destiny handles routes grouped by a single endpoint.
public protocol RouterGroupProtocol : Sendable, ~Copyable {
    /// The parent endpoint all routes registered to this router group are prefixed with.
    var endpoint : String { get }

    /// All the dynamic middleware that is registered to this router group. Ordered in descending order of importance.
    var dynamicMiddleware : [DynamicMiddlewareProtocol] { get }

    /// Get the static responder responsible for a static route based on its path.
    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol?

    /// Gets the dynamic responder responsible for a dynamic route based on its path.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func dynamicResponder<T: RequestProtocol & ~Copyable>(for request: inout T) -> DynamicRouteResponderProtocol?

    /// Registers a static route to this router group after the server has started.
    mutating func register(_ route: StaticRouteProtocol) throws

    /// Registers a dynamic route with its responder to this router group after the server has started.
    mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol) throws

    /// Registers a static middleware at the given index to this router group after the server has started.
    mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router group after the server has started.
    mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws
}