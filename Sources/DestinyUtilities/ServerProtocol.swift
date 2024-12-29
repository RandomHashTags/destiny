//
//  ServerProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import Logging
import ServiceLifecycle

/// The core Server protocol that accepts and processes incoming network requests.
public protocol ServerProtocol : Service {
    typealias ClientSocket = SocketProtocol & ~Copyable

    /// The main router for the server.
    var router : RouterProtocol { get }

    /// The main logger for the server.
    var logger : Logger { get }

    /// Called when the server loads successfully, just before it accepts incoming network requests.
    var onLoad : (@Sendable () -> Void)? { get }

    /// Called when the server terminates.
    var onShutdown : (@Sendable () -> Void)? { get }

    /// Gracefully shuts down the server.
    func shutdown() async throws
}