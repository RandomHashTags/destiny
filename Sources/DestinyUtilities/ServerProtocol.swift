//
//  ServerProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import Logging
import ServiceLifecycle

/// The core Server protocol that handles how Destiny accepts and processes incoming network requests.
public protocol ServerProtocol : Service {
    typealias ClientSocket = SocketProtocol & ~Copyable

    /// The main router for the server.
    var router : RouterProtocol { get }

    var logger : Logger { get }

    /// Called when the server loads successfully, just before it accepts incoming network requests.
    var onLoad : (@Sendable () -> Void)? { get }

    /// Called when the server terminates.
    var onShutdown : (@Sendable () -> Void)? { get }
}