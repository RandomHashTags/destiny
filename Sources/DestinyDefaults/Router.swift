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

/// Default Router implementation that handles middleware, routes and router groups.
public final class Router : RouterProtocol { // TODO: fix Swift 6 errors
    public let version:HTTPVersion
    public private(set) var caseSensitiveResponders:RouterResponderStorage
    public private(set) var caseInsensitiveResponders:RouterResponderStorage

    public private(set) var staticMiddleware:[any StaticMiddlewareProtocol]
    public var dynamicMiddleware:[any DynamicMiddlewareProtocol]

    public private(set) var routerGroups:[any RouterGroupProtocol]
    
    public var errorResponder:any ErrorResponderProtocol
    public var dynamicNotFoundResponder:(any DynamicRouteResponderProtocol)?
    public var staticNotFoundResponder:any StaticRouteResponderProtocol
    
    public init(
        version: HTTPVersion,
        errorResponder: any ErrorResponderProtocol,
        dynamicNotFoundResponder: (any DynamicRouteResponderProtocol)? = nil,
        staticNotFoundResponder: any StaticRouteResponderProtocol,
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
    public func staticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)? {
        if let responder = caseSensitiveResponders.static[startLine] {
            return responder
        }
        return caseInsensitiveResponders.static[startLine.lowercase()]
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
    public func errorResponder(for request: inout any RequestProtocol) -> any ErrorResponderProtocol {
        return errorResponder
    }

    @inlinable
    public func notFoundResponse<C: SocketProtocol & ~Copyable>(socket: borrowing C, request: inout any RequestProtocol) async throws {
        if let responder = dynamicNotFoundResponder { // TODO: support
            //try await responder.respond(to: socket, request: &request, response: &any DynamicResponseProtocol)
        } else {
            try await staticNotFoundResponder.respond(to: socket)
        }
    }

    public func register(_ route: any StaticRouteProtocol, override: Bool = false) throws {
        guard let responder = try route.responder(context: nil, function: nil, middleware: staticMiddleware) else { return }
        var string = route.startLine
        var buffer = DestinyRoutePathType(&string)
        if route.isCaseSensitive {
            if override || caseSensitiveResponders.static[buffer] == nil {
                caseSensitiveResponders.static[buffer] = responder
            } else {
                // TODO: throw error
            }
        } else {
            buffer = buffer.lowercase()
            if override || caseInsensitiveResponders.static[buffer] == nil {
                caseInsensitiveResponders.static[buffer] = responder
            } else {
                // TODO: throw error
            }
        }
    }

    public func register(_ route: any DynamicRouteProtocol, responder: any DynamicRouteResponderProtocol, override: Bool = false) throws {
        var copy = route
        copy.applyStaticMiddleware(staticMiddleware)
        if route.isCaseSensitive {
            try caseSensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        } else {
            try caseInsensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        }
    }

    public func register(_ middleware: any StaticMiddlewareProtocol, at index: Int) throws {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }

    @inlinable
    public func register(_ middleware: any DynamicMiddlewareProtocol, at index: Int) throws {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
}

// MARK: Dynamic middleware
extension Router {
    @inlinable
    public func loadDynamicMiddleware() {
        for i in dynamicMiddleware.indices {
            dynamicMiddleware[i].load()
        }
    }

    @inlinable
    public func handleDynamicMiddleware(for request: inout any RequestProtocol, with response: inout any DynamicResponseProtocol) async throws {
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
        guard var request = try socket.loadRequest() else { return }
        //try await process(client: client, received: received, loaded: .now, socket: socket, request: &request, logger: logger)
        // TODO: finish
    }

    /*
    @inlinable
    func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
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
            await errorResponder(for: &request).respond(to: socket, with: error, for: &request, logger: logger)
        }
    }*/
}

/*
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
            } else if let responder = responder as? ConcreteDynamicRouteResponder {
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
}*/