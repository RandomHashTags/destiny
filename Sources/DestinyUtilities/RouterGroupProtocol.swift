//
//  RouterGroupProtocol.swift
//
//
//  Created by Evan Anderson on 11/22/24.
//

/// The core Router Group protocol that powers how Destiny handles routes grouped by a single endpoint.
public protocol RouterGroupProtocol : Sendable, ~Copyable {
    @inlinable func responder(for request: inout RequestProtocol) -> RouteResponderProtocol?
}