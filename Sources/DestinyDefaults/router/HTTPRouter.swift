
import DestinyBlueprint
import Logging

#if canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#endif

public typealias DefaultHTTPRouter = HTTPRouter<
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>, // CaseSensitiveRouterResponderStorage
    RouterResponderStorage<StaticResponderStorage, DynamicResponderStorage>, // CaseInsensitiveRouterResponderStorage
    StaticErrorResponder,  // ErrorResponder
    DynamicRouteResponder, // DynamicNotFoundResponder
    StringWithDateHeader   // StaticNotFoundResponder
>

/// Default HTTPRouter implementation that handles middleware, routes and router groups.
public final class HTTPRouter<
        CaseSensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        CaseInsensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        ErrorResponder: ErrorResponderProtocol,
        DynamicNotFoundResponder: DynamicRouteResponderProtocol,
        StaticNotFoundResponder: StaticRouteResponderProtocol
    >: HTTPRouterProtocol {
    public let caseSensitiveResponders:CaseSensitiveRouterResponderStorage
    public let caseInsensitiveResponders:CaseInsensitiveRouterResponderStorage

    public let staticMiddleware:[any StaticMiddlewareProtocol]
    nonisolated(unsafe) public var opaqueDynamicMiddleware:[any OpaqueDynamicMiddlewareProtocol]

    nonisolated(unsafe) public private(set) var routeGroups:[any RouteGroupProtocol]
    
    public let errorResponder:ErrorResponder?
    public let dynamicNotFoundResponder:DynamicNotFoundResponder?
    public let staticNotFoundResponder:StaticNotFoundResponder?
    
    public init(
        errorResponder: ErrorResponder?,
        dynamicNotFoundResponder: DynamicNotFoundResponder?,
        staticNotFoundResponder: StaticNotFoundResponder?,
        caseSensitiveResponders: CaseSensitiveRouterResponderStorage,
        caseInsensitiveResponders: CaseInsensitiveRouterResponderStorage,
        staticMiddleware: [any StaticMiddlewareProtocol],
        opaqueDynamicMiddleware: [any OpaqueDynamicMiddlewareProtocol],
        routeGroups: [any RouteGroupProtocol]
    ) {
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
    public func load() {
        for i in opaqueDynamicMiddleware.indices {
            opaqueDynamicMiddleware[i].load()
        }
    }

    @inlinable
    public func handleDynamicMiddleware(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) async throws(ResponderError) {
        for middleware in opaqueDynamicMiddleware {
            do throws(MiddlewareError) {
                if try await !middleware.handle(request: &request, response: &response) {
                    break
                }
            } catch {
                throw .middlewareError(error)
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
            defer {
                #if canImport(SwiftGlibc) || canImport(Foundation)
                shutdown(client, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
                close(client)
                #else
                #warning("Unable to shutdown and close client file descriptor!")
                #endif
            }
            do throws(SocketError) {
                var request = try socket.loadRequest()
                #if DEBUG
                logger.info("\(request.startLine.stringSIMD())")
                #endif
                do throws(ResponderError) {
                    guard !(try await respond(client: client, socket: socket, request: &request, logger: logger)) else { return }
                    // not found
                    if let dynamicNotFoundResponder {
                        var response = try await defaultDynamicResponse(request: &request, responder: dynamicNotFoundResponder)
                        try await dynamicNotFoundResponder.respond(to: socket, request: &request, response: &response)
                    } else if let staticNotFoundResponder {
                        do throws(SocketError) {
                            try await staticNotFoundResponder.write(to: socket)
                        } catch {
                            throw .socketError(error)
                        }
                    }
                } catch {
                    logger.warning("Encountered error while processing client: \(error)")
                    if let errorResponder {
                        await errorResponder.respond(socket: socket, error: error, request: &request, logger: logger)
                    }
                }
            } catch {
                logger.warning("Encountered error while loading request: \(error)")
            }
        }
    }
}

// MARK: Respond
extension HTTPRouter {
    @inlinable
    public func respond(
        client: Int32,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) async throws(ResponderError) -> Bool {
        if try await caseSensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLine) {
        } else if try await caseInsensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLineLowercased()) {
        } else if try await caseSensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) {
        } else if try await caseInsensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) { // TODO: support
        } else {
            for group in routeGroups {
                if try await group.respond(router: self, socket: socket, request: &request) {
                    return true
                }
            }
            return false
        }
        return true
    }
}