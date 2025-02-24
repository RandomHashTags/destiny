//
//  ServerProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import ArgumentParser
import Logging
import ServiceLifecycle

/// Core Server protocol that accepts and processes incoming network requests.
public protocol ServerProtocol : Service {
    /// Main logger for the server.
    var logger : Logger { get }

    /// Commands that can be executed from the terminal when the server is running.
    var commands : [ParsableCommand.Type] { get }

    /// When the server loads successfully, just before it accepts incoming network requests.
    var onLoad : (@Sendable () -> Void)? { get }

    /// When the server terminates.
    var onShutdown : (@Sendable () -> Void)? { get }
}