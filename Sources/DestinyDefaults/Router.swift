//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

#if canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint
import DestinyUtilities
import Logging

public typealias DefaultRouter = Router<
    StaticErrorResponder,       // ConcreteErrorResponder
    DynamicRouteResponder,      // ConcreteDynamicNotFoundResponder
    RouteResponses.StaticString // ConcreteStaticNotFoundResponder
>

/// Default Router implementation that handles middleware, routes and router groups.
public struct Router<
        ConcreteErrorResponder: ErrorResponderProtocol,
        ConcreteDynamicNotFoundResponder: DynamicRouteResponderProtocol,
        ConcreteStaticNotFoundResponder: StaticRouteResponderProtocol
    >: RouterProtocol {
    public private(set) var caseSensitiveResponders:RouterResponderStorage
    public private(set) var caseInsensitiveResponders:RouterResponderStorage

    public private(set) var staticMiddleware:[any StaticMiddlewareProtocol]
    public var dynamicMiddleware:[any DynamicMiddlewareProtocol]

    public private(set) var routerGroups:[any RouterGroupProtocol]
    
    public var errorResponder:ConcreteErrorResponder
    public var dynamicNotFoundResponder:ConcreteDynamicNotFoundResponder?
    public var staticNotFoundResponder:ConcreteStaticNotFoundResponder

    public let version:HTTPVersion
    
    public init(
        version: HTTPVersion,
        errorResponder: ConcreteErrorResponder,
        dynamicNotFoundResponder: ConcreteDynamicNotFoundResponder? = nil,
        staticNotFoundResponder: ConcreteStaticNotFoundResponder,
        caseSensitiveResponders: RouterResponderStorage,
        caseInsensitiveResponders: RouterResponderStorage,
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        routerGroups: [any RouterGroupProtocol]
    ) {
        self.version = version
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.caseSensitiveResponders = caseSensitiveResponders
        self.caseInsensitiveResponders = caseInsensitiveResponders
        self.dynamicMiddleware = dynamicMiddleware
        self.staticMiddleware = staticMiddleware
        self.routerGroups = routerGroups
    }

    @inlinable
    public func dynamicResponder(for request: inout any RequestProtocol) -> (any DynamicRouteResponderProtocol)? {
        if let responder = caseSensitiveResponders.dynamic.responder(for: &request) {
            return responder
        }
        //request.startLine = toLowercase(path: request.startLine) // TODO: finish
        return caseInsensitiveResponders.dynamic.responder(for: &request)
    }
    
    @inlinable
    public func conditionalResponder(for request: inout any RequestProtocol) -> (any RouteResponderProtocol)? {
        if let responder = caseSensitiveResponders.conditional[request.startLine]?.responder(for: &request) {
            return responder
        }
        return caseInsensitiveResponders.conditional[request.startLine.lowercase()]?.responder(for: &request)
    }

    @inlinable
    public func routerGroupStaticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)? {
        for group in routerGroups {
            if let responder = group.staticResponder(for: startLine) {
                return responder
            }
        }
        return nil
    }

    @inlinable
    public func routerGroupDynamicResponder(for request: inout any RequestProtocol) -> (any DynamicRouteResponderProtocol)? {
        for group in routerGroups {
            if let responder = group.dynamicResponder(for: &request) {
                return responder
            }
        }
        return nil
    }

    @inlinable
    public func notFoundResponse<Socket: SocketProtocol & ~Copyable>(socket: borrowing Socket, request: inout any RequestProtocol) async throws {
        if let dynamicNotFoundResponder { // TODO: support
            //try await dynamicNotFoundResponder.respond(to: socket, request: &request, response: &any DynamicResponseProtocol)
        } else {
            try await staticNotFoundResponder.respond(to: socket)
        }
    }
}

// MARK: Dynamic middleware
extension Router {
    @inlinable
    public mutating func loadDynamicMiddleware() {
        for i in dynamicMiddleware.indices {
            dynamicMiddleware[i].load()
        }
    }

    @inlinable
    func handleDynamicMiddleware(for request: inout any RequestProtocol, with response: inout any DynamicResponseProtocol) async throws {
        for middleware in dynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }
}

// MARK: Process
extension Router {
    @inlinable
    public func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws {
        guard var request:any RequestProtocol = try Socket.ConcreteRequest(socket: socket) else { return }
        try await process(client: client, received: received, loaded: .now, socket: socket, request: &request, logger: logger)
    }

    @inlinable
    func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol,
        logger: Logger
    ) async throws {
        defer {
            #if canImport(Foundation)
            shutdown(client, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
            close(client)
            #else
            #warning("Unable to shutdown and close client file descriptor!")
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
            await errorResponder.respond(to: socket, with: error, for: &request, logger: logger)
        }
    }
}

// MARK: Respond
extension Router {
    @inlinable
    func respond<Socket: SocketProtocol & ~Copyable>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol
    ) async throws -> Bool {
        if try await caseSensitiveResponders.static.respond(to: socket, with: request.startLine) {
        } else if try await caseInsensitiveResponders.static.respond(to: socket, with: request.startLine) {
        } else if let responder = dynamicResponder(for: &request) {
            try await dynamicResponse(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
        } else if let responder = conditionalResponder(for: &request) {
            if let staticResponder = responder as? any StaticRouteResponderProtocol {
                try await staticResponse(socket: socket, responder: staticResponder)
            } else if let responder = responder as? any DynamicRouteResponderProtocol {
                try await dynamicResponse(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
            }
        } else {
            for group in routerGroups {
                if let responder = group.staticResponder(for: request.startLine) {
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

    @inlinable
    func staticResponse<Socket: SocketProtocol & ~Copyable>(
        socket: borrowing Socket,
        responder: any StaticRouteResponderProtocol
    ) async throws {
        try await responder.respond(to: socket)
    }

    @inlinable
    func dynamicResponse<Socket: SocketProtocol & ~Copyable>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol,
        responder: any DynamicRouteResponderProtocol
    ) async throws {
        var response = responder.defaultResponse
        response.timestamps.received = received
        response.timestamps.loaded = loaded
        var index = 0
        responder.forEachPathComponentParameterIndex { parameterIndex in
            response.parameters[index] = request.path(at: parameterIndex)
            if responder.pathComponent(at: parameterIndex) == .catchall {
                var i = parameterIndex+1
                while i < request.pathCount {
                    response.parameters.append(request.path(at: i))
                    i += 1
                }
            }
            index += 1
        }
        try await handleDynamicMiddleware(for: &request, with: &response)
        response.timestamps.processed = .now
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}