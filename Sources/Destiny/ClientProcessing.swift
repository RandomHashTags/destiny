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

public enum ClientProcessing {
    // MARK: Process
    @inlinable
    static func process<C: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing C,
        logger: Logger,
        router: RouterProtocol
    ) async throws {
        guard var request:RequestProtocol = try socket.loadRequest() else { return }
        try await process(client: client, received: received, loaded: .now, socket: socket, request: &request, logger: logger, router: router)
    }
    @inlinable
    static func process<C: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing C,
        request: inout RequestProtocol,
        logger: Logger,
        router: RouterProtocol
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
            if try await !respond(received: received, loaded: loaded, socket: socket, request: &request, router: router) {
                try await router.notFoundResponse(socket: socket, request: &request)
            }
        } catch {
            await router.errorResponder(for: &request).respond(to: socket, with: error, for: &request, logger: logger)
        }
    }

    // MARK: Respond
    @inlinable
    static func respond<C: SocketProtocol & ~Copyable>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing C,
        request: inout RequestProtocol,
        router: RouterProtocol
    ) async throws -> Bool {
        if let responder:StaticRouteResponderProtocol = router.staticResponder(for: request.startLine) {
            try await staticResponse(socket: socket, responder: responder)
        } else if let responder:DynamicRouteResponderProtocol = router.dynamicResponder(for: &request) {
            try await dynamicResponse(received: received, loaded: loaded, socket: socket, router: router, request: &request, responder: responder)
        } else if let responder:RouteResponderProtocol = router.conditionalResponder(for: &request) {
            if let staticResponder:StaticRouteResponderProtocol = responder as? StaticRouteResponderProtocol {
                try await staticResponse(socket: socket, responder: staticResponder)
            } else if let responder:DynamicRouteResponderProtocol = responder as? DynamicRouteResponderProtocol {
                try await dynamicResponse(received: received, loaded: loaded, socket: socket, router: router, request: &request, responder: responder)
            }
        } else {
            for group in router.routerGroups {
                if let responder:StaticRouteResponderProtocol = group.staticResponder(for: request.startLine) {
                    try await staticResponse(socket: socket, responder: responder)
                    return true
                } else if let responder:DynamicRouteResponderProtocol = group.dynamicResponder(for: &request) {
                    try await dynamicResponse(received: received, loaded: loaded, socket: socket, router: router, request: &request, responder: responder)
                    return true
                }
            }
            return false
        }
        return true
    }

    // MARK: Static Response
    @inlinable
    static func staticResponse<C: SocketProtocol & ~Copyable>(
        socket: borrowing C,
        responder: StaticRouteResponderProtocol
    ) async throws {
        try await responder.respond(to: socket)
    }

    // MARK: Dynamic Response
    @inlinable
    static func dynamicResponse<C: SocketProtocol & ~Copyable>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing C,
        router: RouterProtocol,
        request: inout RequestProtocol,
        responder: DynamicRouteResponderProtocol
    ) async throws {
        var response:DynamicResponseProtocol = responder.defaultResponse
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
        for middleware in router.dynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
        response.timestamps.processed = .now
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}