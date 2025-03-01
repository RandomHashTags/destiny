//
//  ClientProcessing.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

#if canImport(Foundation)
import Foundation
#endif

import Logging

extension RouterProtocol {
    // MARK: Process
    @inlinable
    func process(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        logger: Logger
    ) async throws {
        guard var request:ConcreteSocket.ConcreteRequest = try socket.loadRequest() else { return }
        try await process(client: client, received: received, loaded: .now, socket: socket, request: &request, logger: logger)
    }
    @inlinable
    func process(
        client: Int32,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest,
        logger: Logger
    ) async throws {
        defer {
            #if canImport(Foundation)
            shutdown(client, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
            close(client)
            #else
            #warning("Unable to shutdown and close client file descriptors!")
            #endif
        }
        #if DEBUG
        logger.info(Logger.Message(stringLiteral: request.startLine.stringSIMD()))
        #endif
        do {
            if try await !respond(received: received, loaded: loaded, socket: socket, request: &request) {
                try await notFoundResponse(socket: socket, request: &request)
            }
        } catch {
            await errorResponder(for: &request).respond(to: socket, with: error, for: &request, logger: logger)
        }
    }

    // MARK: Respond
    @inlinable
    func respond(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest
    ) async throws -> Bool {
        if let responder:any StaticRouteResponderProtocol = staticResponder(for: request.startLine) {
            try await staticResponse(socket: socket, responder: responder)
        } else if let responder = dynamicResponder(for: &request) {
            try await dynamicResponse(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
        } else if let responder:any RouteResponderProtocol = conditionalResponder(for: &request) {
            if let staticResponder:any StaticRouteResponderProtocol = responder as? any StaticRouteResponderProtocol {
                try await staticResponse(socket: socket, responder: staticResponder)
            } else if let responder = responder as? ConcreteDynamicRouteResponder {
                try await dynamicResponse(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
            }
        } else {
            for group in routerGroups {
                if let responder:any StaticRouteResponderProtocol = group.staticResponder(for: request.startLine) {
                    try await staticResponse(socket: socket, responder: responder)
                    return true
                } else if let responder = group.dynamicResponder(for: &request) {
                    try await dynamicResponse(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
                    return true
                }
            }
            return false
        }
        return true
    }

    // MARK: Static Response
    @inlinable
    func staticResponse(
        socket: borrowing ConcreteSocket,
        responder: any StaticRouteResponderProtocol
    ) async throws {
        try await responder.respond(to: socket)
    }

    // MARK: Dynamic Response
    @inlinable
    func dynamicResponse(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest,
        responder: ConcreteDynamicRouteResponder
    ) async throws {
        var response:ConcreteDynamicRouteResponder.ConcreteResponse = responder.defaultResponse
        response.timestamps.received = received
        response.timestamps.loaded = loaded
        for (index, parameterIndex) in responder.parameterPathIndexes.enumerated() {
            response.parameters[index] = request.path[parameterIndex]
            if responder.path[parameterIndex] == .catchall {
                var i:Int = parameterIndex+1
                while i < request.path.count {
                    response.parameters.append(request.path[i])
                    i += 1
                }
            }
        }
        try await handleDynamicMiddleware(for: &request, with: &response)
        response.timestamps.processed = .now
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}