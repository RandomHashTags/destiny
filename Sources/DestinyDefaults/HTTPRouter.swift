
import DestinyBlueprint
import Logging

#if canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#endif

public typealias DefaultRouter = HTTPRouter<
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>,     // ConcreteCaseSensitiveRouterResponderStorage
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>,     // ConcreteCaseInsensitiveRouterResponderStorage
    StaticErrorResponder,       // ConcreteErrorResponder
    DynamicRouteResponder,      // ConcreteDynamicNotFoundResponder
    StringWithDateHeader // ConcreteStaticNotFoundResponder
>

/// Default HTTPRouter implementation that handles middleware, routes and router groups.
public final class HTTPRouter<
        ConcreteCaseSensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        ConcreteCaseInsensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        ConcreteErrorResponder: ErrorResponderProtocol,
        ConcreteDynamicNotFoundResponder: DynamicRouteResponderProtocol,
        ConcreteStaticNotFoundResponder: StaticRouteResponderProtocol
    >: HTTPRouterProtocol {
    public let caseSensitiveResponders:ConcreteCaseSensitiveRouterResponderStorage
    public let caseInsensitiveResponders:ConcreteCaseInsensitiveRouterResponderStorage

    public private(set) var staticMiddleware:[any StaticMiddlewareProtocol]
    public var opaqueDynamicMiddleware:[any OpaqueDynamicMiddlewareProtocol]

    public private(set) var routeGroups:[any RouteGroupProtocol]
    
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
        opaqueDynamicMiddleware: [any OpaqueDynamicMiddlewareProtocol],
        routeGroups: [any RouteGroupProtocol]
    ) {
        self.version = version
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.caseSensitiveResponders = caseSensitiveResponders
        self.caseInsensitiveResponders = caseInsensitiveResponders
        self.opaqueDynamicMiddleware = opaqueDynamicMiddleware
        self.staticMiddleware = staticMiddleware
        self.routeGroups = routeGroups
    }
}

// MARK: Dynamic middleware
extension HTTPRouter {
    @inlinable
    public func loadDynamicMiddleware() {
        for i in opaqueDynamicMiddleware.indices {
            opaqueDynamicMiddleware[i].load()
        }
    }

    @inlinable
    func handleDynamicMiddleware(for request: inout some HTTPRequestProtocol & ~Copyable, with response: inout some DynamicResponseProtocol) async throws {
        for middleware in opaqueDynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }
}

// MARK: Handle
extension HTTPRouter {
    @inlinable
    public func handle(
        client: Int32,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        logger: Logger
    ) {
        Task {
            do {
                var request = try socket.loadRequest()
                try await process(client: client, socket: socket, request: &request, logger: logger)
            } catch {
                logger.warning("Encountered error while processing client: \(error)")
            }
        }
    }
}

// MARK: Process
extension HTTPRouter {
    @inlinable
    func process(
        client: Int32,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) async throws {
        defer {
            #if canImport(SwiftGlibc) || canImport(Foundation)
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
            } else if try await caseSensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) {
            } else if try await caseInsensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) { // TODO: support
            } else {
                for group in routeGroups {
                    if try await group.respond(router: self, socket: socket, request: &request) {
                        return
                    }
                }
                // not found
                if let dynamicNotFoundResponder {
                    var response = try await defaultDynamicResponse(request: &request, responder: dynamicNotFoundResponder)
                    try await dynamicNotFoundResponder.respond(to: socket, request: &request, response: &response)
                } else {
                    try await staticNotFoundResponder.write(to: socket)
                }
            }
        } catch {
            await errorResponder.respond(socket: socket, error: error, request: &request, logger: logger)
        }
    }
}

// MARK: Respond
extension HTTPRouter {
    @inlinable
    public func respondStatically(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        responder: borrowing some StaticRouteResponderProtocol
    ) async throws {
        try await responder.write(to: socket)
    }

    @inlinable
    func defaultDynamicResponse(
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) async throws -> any DynamicResponseProtocol {
        var response = responder.defaultResponse
        var index = 0
        let maximumParameters = responder.pathComponentsCount
        responder.forEachPathComponentParameterIndex { parameterIndex in
            request.path(at: parameterIndex).inlineVLArray {
                response.setParameter(at: index, value: $0)
            }
            if responder.pathComponent(at: parameterIndex) == .catchall {
                var i = parameterIndex+1
                request.forEachPath(offset: i) { path in
                    path.inlineVLArray {
                        if i < maximumParameters {
                            response.setParameter(at: i, value: $0)
                        } else {
                            response.appendParameter(value: $0)
                        }
                    }
                    i += 1
                }
            }
            index += 1
        }
        try await handleDynamicMiddleware(for: &request, with: &response)
        return response
    }

    @inlinable
    public func respondDynamically(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) async throws {
        var response = try await defaultDynamicResponse(request: &request, responder: responder)
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}