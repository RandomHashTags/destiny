//
//  ConditionalRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

/// The core Conditional Route Responder protocol that selects a route responder based on a request.
public protocol ConditionalRouteResponderProtocol : CustomDebugStringConvertible, RouteResponderProtocol {
    /// - Parameters:
    ///   - request: The request.
    /// - Returns: The responder for the request.
    func responder(for request: inout RequestProtocol) -> RouteResponderProtocol?
}