//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities

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
    public private(set) var caseSensitiveResponders:RouterResponderStorage<ConcreteSocket.ConcreteRequest>
    public private(set) var caseInsensitiveResponders:RouterResponderStorage<ConcreteSocket.ConcreteRequest>

    public private(set) var staticMiddleware:[ConcreteStaticMiddleware]
    public var dynamicMiddleware:[ConcreteDynamicMiddleware]

    public private(set) var routerGroups:[ConcreteRouterGroup]
    
    public var errorResponder:ConcreteErrorResponder
    public var dynamicNotFoundResponder:ConcreteDynamicRouteResponder?
    public var staticNotFoundResponder:any StaticRouteResponderProtocol
    
    public init(
        version: HTTPVersion,
        errorResponder: ConcreteErrorResponder,
        dynamicNotFoundResponder: ConcreteDynamicRouteResponder? = nil,
        staticNotFoundResponder: any StaticRouteResponderProtocol,
        caseSensitiveResponders: RouterResponderStorage<Request>,
        caseInsensitiveResponders: RouterResponderStorage<Request>,
        staticMiddleware: [ConcreteStaticMiddleware],
        dynamicMiddleware: [ConcreteDynamicMiddleware],
        routerGroups: [RouterGroup]
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
    public func loadDynamicMiddleware() {
        for index in dynamicMiddleware.indices {
            dynamicMiddleware[index].load()
        }
    }

    @inlinable
    public func handleDynamicMiddleware(for request: inout ConcreteSocket.ConcreteRequest, with response: inout ConcreteDynamicResponse) async throws {
        for middleware in dynamicMiddleware {
            if try await !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)? {
        if let responder:any StaticRouteResponderProtocol = caseSensitiveResponders.static[startLine] {
            return responder
        }
        return caseInsensitiveResponders.static[toLowercase(path: startLine)]
    }
    @inlinable
    public func dynamicResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteDynamicRouteResponder? {
        if let responder:ConcreteDynamicRouteResponder = caseSensitiveResponders.dynamic.responder(for: &request) {
            return responder
        }
        //request.startLine = toLowercase(path: request.startLine) // TODO: finish
        return caseInsensitiveResponders.dynamic.responder(for: &request)
    }
    
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

    @inlinable
    public func errorResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteErrorResponder {
        return errorResponder
    }

    @inlinable
    public func notFoundResponse(socket: borrowing ConcreteSocket, request: inout ConcreteSocket.ConcreteRequest) async throws {
        if let responder:ConcreteDynamicRouteResponder = dynamicNotFoundResponder { // TODO: support
            //try await responder.respond(to: socket, request: &request, response: &any DynamicResponseProtocol)
        } else {
            try await staticNotFoundResponder.respond(to: socket)
        }
    }

    public func register(_ route: ConcreteStaticRoute, override: Bool = false) throws {
        guard let responder:any StaticRouteResponderProtocol = try route.responder(context: nil, function: nil, middleware: staticMiddleware) else { return }
        var string:String = route.startLine
        var buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        if route.isCaseSensitive {
            if override || caseSensitiveResponders.static[buffer] == nil {
                caseSensitiveResponders.static[buffer] = responder
            } else {
                // TODO: throw error
            }
        } else {
            buffer = toLowercase(path: buffer)
            if override || caseInsensitiveResponders.static[buffer] == nil {
                caseInsensitiveResponders.static[buffer] = responder
            } else {
                // TODO: throw error
            }
        }
    }

    public func register(
        _ route: ConcreteDynamicRoute,
        responder: ConcreteDynamicRoute.ConcreteResponder,
        override: Bool = false
    ) throws {
        var copy:ConcreteDynamicRoute = route
        copy.applyStaticMiddleware(staticMiddleware)
        if route.isCaseSensitive {
            try caseSensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        } else {
            try caseInsensitiveResponders.dynamic.register(version: copy.version, route: copy, responder: responder, override: override)
        }
    }

    public func register(_ middleware: ConcreteStaticMiddleware, at index: Int) throws {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }

    @inlinable
    public func register(_ middleware: ConcreteDynamicMiddleware, at index: Int) throws {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
}

extension Router {
    @inlinable
    func toLowercase(path: DestinyRoutePathType) -> DestinyRoutePathType {
        var upperCase:SIMDMask<SIMD64<UInt8>.MaskStorage> = path .>= 65
        upperCase .&= path .<= 90

        var addition:DestinyRoutePathType = .zero
        addition.replace(with: 32, where: upperCase)
        return path &+ addition
    }
}