//
//  ErrorResponderProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

import Logging

// The core Error Middleware protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol : RouteResponderProtocol { // TODO: finish
    /// Writes a response to a socket.
    @inlinable func respond<T: SocketProtocol & ~Copyable, E: Error>(
        to socket: borrowing T,
        with error: E,
        for request: inout RequestProtocol,
        logger: Logger
    ) async
}