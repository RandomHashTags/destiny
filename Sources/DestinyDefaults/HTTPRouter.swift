
#if canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint
import Logging

public typealias DefaultRouter = HTTPRouter<
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>,     // ConcreteCaseSensitiveRouterResponderStorage
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>,     // ConcreteCaseInsensitiveRouterResponderStorage
    StaticErrorResponder,       // ConcreteErrorResponder
    DynamicRouteResponder,      // ConcreteDynamicNotFoundResponder
    RouteResponses.StaticStringWithDateHeader // ConcreteStaticNotFoundResponder
>

/// Default HTTPRouter implementation that handles middleware, routes and router groups.
public struct HTTPRouter<
        ConcreteCaseSensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        ConcreteCaseInsensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        ConcreteErrorResponder: ErrorResponderProtocol,
        ConcreteDynamicNotFoundResponder: DynamicRouteResponderProtocol,
        ConcreteStaticNotFoundResponder: StaticRouteResponderProtocol
    >: HTTPRouterProtocol {
    public private(set) var caseSensitiveResponders:ConcreteCaseSensitiveRouterResponderStorage
    public private(set) var caseInsensitiveResponders:ConcreteCaseInsensitiveRouterResponderStorage

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
        dynamicNotFoundResponder: ConcreteDynamicNotFoundResponder?,
        staticNotFoundResponder: ConcreteStaticNotFoundResponder,
        caseSensitiveResponders: ConcreteCaseSensitiveRouterResponderStorage,
        caseInsensitiveResponders: ConcreteCaseInsensitiveRouterResponderStorage,
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
}

// MARK: Dynamic middleware
extension HTTPRouter {
    @inlinable
    public mutating func loadDynamicMiddleware() {
        for i in dynamicMiddleware.indices {
            dynamicMiddleware[i].load()
        }
    }

    @inlinable
    func handleDynamicMiddleware(for request: inout any HTTPRequestProtocol, with response: inout any DynamicResponseProtocol) async throws {
        for middleware in dynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }
}

// MARK: Process
extension HTTPRouter {
    @inlinable
    public func process<Socket: HTTPSocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws {
        guard var request = try Socket.ConcreteRequest(socket: socket) else { return }
        try await process(client: client, received: received, loaded: .now, socket: socket, request: &request, logger: logger)
    }

    @inlinable
    func process<Socket: HTTPSocketProtocol & ~Copyable>(
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
            if try await caseSensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLine) {
            } else if try await caseInsensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLine.lowercased()) {
            } else if try await caseSensitiveResponders.respondDynamically(router: self, received: received, loaded: loaded, socket: socket, request: &request) {
            } else if try await caseInsensitiveResponders.respondDynamically(router: self, received: received, loaded: loaded, socket: socket, request: &request) { // TODO: support
            } else {
                for group in routerGroups {
                    if try await group.respond(router: self, received: received, loaded: loaded, socket: socket, request: &request) {
                        return
                    }
                }
                // not found
                if let dynamicNotFoundResponder {
                    var anyRequest:any HTTPRequestProtocol = request
                    var response = try await defaultDynamicResponse(received: received, loaded: loaded, request: &anyRequest, responder: dynamicNotFoundResponder)
                    try await dynamicNotFoundResponder.respond(to: socket, request: &anyRequest, response: &response)
                } else {
                    try await staticNotFoundResponder.respond(to: socket)
                }
            }
        } catch {
            var anyRequest:any HTTPRequestProtocol = request
            await errorResponder.respond(to: socket, with: error, for: &anyRequest, logger: logger)
        }
    }
}

// MARK: Respond
extension HTTPRouter {
    @inlinable
    public func respondStatically<Socket: HTTPSocketProtocol & ~Copyable, Responder: StaticRouteResponderProtocol>(
        socket: borrowing Socket,
        responder: Responder
    ) async throws {
        try await responder.respond(to: socket)
    }

    @inlinable
    func defaultDynamicResponse<Responder: DynamicRouteResponderProtocol>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        request: inout any HTTPRequestProtocol,
        responder: Responder
    ) async throws -> any DynamicResponseProtocol {
        var response = responder.defaultResponse
        response.timestamps.received = received
        response.timestamps.loaded = loaded
        var index = 0
        responder.forEachPathComponentParameterIndex { parameterIndex in
            request.path(at: parameterIndex).inlineVLArray {
                response.setParameter(at: index, value: $0)
            }
            if responder.pathComponent(at: parameterIndex) == .catchall {
                var i = parameterIndex+1
                request.forEachPath(offset: i) { path in
                    path.inlineVLArray {
                        response.setParameter(at: i, value: $0)
                    }
                    i += 1
                }
            }
            index += 1
        }
        try await handleDynamicMiddleware(for: &request, with: &response)
        response.timestamps.processed = .now
        return response
    }

    @inlinable
    public func respondDynamically<Socket: HTTPSocketProtocol & ~Copyable, Responder: DynamicRouteResponderProtocol>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
        responder: Responder
    ) async throws {
        var anyRequest:any HTTPRequestProtocol = request
        var response = try await defaultDynamicResponse(received: received, loaded: loaded, request: &anyRequest, responder: responder)
        try await responder.respond(to: socket, request: &anyRequest, response: &response)
    }
}