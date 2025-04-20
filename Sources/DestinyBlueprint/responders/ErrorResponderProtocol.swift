//
//  ErrorResponderProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

import Logging

/// Core Error Middleware protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol : RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable
    func respond<T: SocketProtocol & ~Copyable, E: Error>(
        to socket: borrowing T,
        with error: E,
        for request: inout any RequestProtocol,
        logger: Logger
    ) async
}