//
//  RouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// The core Route Responder protocol that powers Destiny's route responses.
public protocol RouteResponderProtocol : CustomDebugStringConvertible, Sendable {
    /// Whether or not this `RouteResponderProtocol` responds asynchronously or synchronously.
    @inlinable var isAsync : Bool { get }
}