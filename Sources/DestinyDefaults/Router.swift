//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities
import Logging

#if canImport(Foundation)
import Foundation
#endif

/// Default Router implementation that handles middleware, routes and router groups.
public final class Router : RouterProtocol { // TODO: fix Swift 6 errors

    public typealias ConcreteSocket = Socket
    public typealias ConcreteStaticRoute = StaticRoute
    public typealias ConcreteDynamicRoute = DynamicRoute
    public typealias ConcreteStaticMiddleware = StaticMiddleware
    public typealias ConcreteDynamicMiddleware = DynamicMiddleware
    public typealias ConcreteDynamicRouteResponder = DynamicRouteResponder
    public typealias ConcreteDynamicResponse = DynamicResponse
    public typealias ConcreteErrorResponder = StaticErrorResponder
    public typealias ConcreteRouterGroup = RouterGroup

    public let version:HTTPVersion
    public private(set) var caseSensitiveResponders:RouterResponderStorage
    public private(set) var caseInsensitiveResponders:RouterResponderStorage

    public private(set) var staticMiddleware:[ConcreteStaticMiddleware]
    public var dynamicMiddleware:[ConcreteDynamicMiddleware]
    public var dynamicCORSMiddleware:DynamicCORSMiddleware?
    public var dynamicDateMiddleware:DynamicDateMiddleware?

    public private(set) var routerGroups:[ConcreteRouterGroup]
    
    public var errorResponder:ConcreteErrorResponder
    public var dynamicNotFoundResponder:ConcreteDynamicRouteResponder?
    public var staticNotFoundResponder:any StaticRouteResponderProtocol
    
    public init(
        version: HTTPVersion,
        errorResponder: ConcreteErrorResponder,
        dynamicNotFoundResponder: ConcreteDynamicRouteResponder? = nil,
        staticNotFoundResponder: any StaticRouteResponderProtocol,
        caseSensitiveResponders: RouterResponderStorage = .init(),
        caseInsensitiveResponders: RouterResponderStorage = .init(),
        staticMiddleware: [ConcreteStaticMiddleware] = [],
        dynamicMiddleware: [ConcreteDynamicMiddleware] = [],
        dynamicCORSMiddleware: DynamicCORSMiddleware? = nil,
        dynamicDateMiddleware: DynamicDateMiddleware? = nil,
        routerGroups: [RouterGroup] = []
    ) {
        self.version = version
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.caseSensitiveResponders = caseSensitiveResponders
        self.caseInsensitiveResponders = caseInsensitiveResponders
        self.dynamicMiddleware = dynamicMiddleware
        self.dynamicCORSMiddleware = dynamicCORSMiddleware
        self.dynamicDateMiddleware = dynamicDateMiddleware
        self.staticMiddleware = staticMiddleware
        self.routerGroups = routerGroups
    }

    @inlinable
    public func loadDynamicMiddleware() {
        dynamicCORSMiddleware?.load()
        dynamicDateMiddleware?.load()
        for index in dynamicMiddleware.indices {
            dynamicMiddleware[index].load()
        }
    }

    @inlinable
    public func handleDynamicMiddleware(for request: inout ConcreteSocket.ConcreteRequest, with response: inout ConcreteDynamicResponse) async throws {
        if let m = dynamicCORSMiddleware, try await !m.handle(request: &request, response: &response) {
            return
        }
        if let m = dynamicDateMiddleware, try await !m.handle(request: &request, response: &response) {
        }
        for middleware in dynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }
}

// MARK: Responders
extension Router {
    /// The dynamic responder responsible for a dynamic route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable
    public func dynamicResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteDynamicRouteResponder? {
        if let responder:ConcreteDynamicRouteResponder = caseSensitiveResponders.dynamic.responder(for: &request) {
            return responder
        }
        //request.startLine = toLowercase(path: request.startLine) // TODO: finish
        return caseInsensitiveResponders.dynamic.responder(for: &request)
    }
    
    /// The conditional responder responsible for a route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable
    public func conditionalResponder(for request: inout ConcreteSocket.ConcreteRequest) -> (any RouteResponderProtocol)? {
        if let responder:any RouteResponderProtocol = caseSensitiveResponders.conditional[request.startLine]?.responder(for: &request) {
            return responder
        }
        return caseInsensitiveResponders.conditional[toLowercase(path: request.startLine)]?.responder(for: &request)
    }

    @inlinable
    public func routerGroupStaticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)? {
        for group in routerGroups {
            if let responder:any StaticRouteResponderProtocol = group.staticResponder(for: startLine) {
                return responder
            }
        }
        return nil
    }

    @inlinable
    public func routerGroupDynamicResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteDynamicRouteResponder? {
        for group in routerGroups {
            if let responder = group.dynamicResponder(for: &request) {
                return responder
            }
        }
        return nil
    }

    /// The error responder.
    @inlinable
    public func errorResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteErrorResponder {
        return errorResponder
    }

    /// The responder for requests to unregistered endpoints.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable
    public func notFoundResponse(socket: borrowing ConcreteSocket, request: inout ConcreteSocket.ConcreteRequest) async throws {
        if let responder:ConcreteDynamicRouteResponder = dynamicNotFoundResponder {
            var response = responder.defaultResponse
            try await responder.respond(to: socket, request: &request, response: &response)
        } else {
            try await staticNotFoundResponder.respond(to: socket)
        }
    }
}

// MARK: Register
extension Router {
    /// Registers a static route to this router.
    /// 
    /// - Parameters:
    ///   - route: The static route you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    public func register(_ route: ConcreteStaticRoute, override: Bool = false) throws {
        guard let responder:any StaticRouteResponderProtocol = try route.responder(context: nil, function: nil, middleware: staticMiddleware) else { return }
        var string = route.startLine
        var buffer = DestinyRoutePathType(&string)
        if route.isCaseSensitive {
            if override || !caseSensitiveResponders.static.exists(for: buffer) {
                //caseSensitiveResponders.static[buffer] = responder // TODO: fix
            } else {
                // TODO: throw error
            }
        } else {
            buffer = toLowercase(path: buffer)
            if override || !caseInsensitiveResponders.static.exists(for: buffer) {
                //caseInsensitiveResponders.static[buffer] = responder // TODO: fix
            } else {
                // TODO: throw error
            }
        }
    }

    /// Registers a dynamic route with its responder to this router.
    /// 
    /// - Parameters:
    ///   - route: The dynamic route you want to register.
    ///   - responder: The dynamic responder you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    public func register(
        _ route: ConcreteDynamicRoute,
        responder: ConcreteDynamicRoute.ConcreteResponder,
        override: Bool = false
    ) throws {
        var copy = route
        copy.applyStaticMiddleware(staticMiddleware)
        if route.isCaseSensitive {
            try caseSensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        } else {
            try caseInsensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        }
    }

    /// Registers a static middleware at the given index to this router.
    public func register(_ middleware: ConcreteStaticMiddleware, at index: Int) throws {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }

    /// Registers a dynamic middleware at the given index to this router.
    @inlinable
    public func register(_ middleware: ConcreteDynamicMiddleware, at index: Int) throws {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }

    /// Registers a static route with the GET HTTP method to this router.
    //func get(_ path: [String], responder: any RouteResponderProtocol) throws
}
extension Router {
    @inlinable
    func toLowercase(path: DestinyRoutePathType) -> DestinyRoutePathType {
        var upperCase = path .>= 65
        upperCase .&= path .<= 90

        var addition:DestinyRoutePathType = .zero
        addition.replace(with: 32, where: upperCase)
        return path &+ addition
    }
}

// MARK: Process
extension Router {
    @inlinable
    public func process(
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
    }
}

// MARK: Respond
extension Router {
    @inlinable
    func respond(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest
    ) async throws -> Bool {
        if try await caseSensitiveResponders.static.respond(to: socket, with: request.startLine) {
        } else if try await caseInsensitiveResponders.static.respond(to: socket, with: request.startLine) {
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

    @inlinable
    func staticResponse(
        socket: borrowing ConcreteSocket,
        responder: any StaticRouteResponderProtocol
    ) async throws {
        try await responder.respond(to: socket)
    }

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