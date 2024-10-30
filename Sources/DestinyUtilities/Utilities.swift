//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

// MARK: RouterGroup
public struct RouterGroup : Sendable {
    public let method:HTTPRequest.Method?
    public let path:String
    public let routers:[Router]

    public init(
        method: HTTPRequest.Method? = nil,
        path: String,
        routers: [Router]
    ) {
        self.method = method
        self.path = path
        self.routers = routers
    }
}

// MARK: Router
public struct Router : Sendable {
    public let staticResponses:[StackString32:StaticRouteResponseProtocol]
    public let dynamicResponses:[StackString32:DynamicRouteResponseProtocol]
    public let dynamicMiddleware:[DynamicMiddlewareProtocol]
    
    public init(
        staticResponses: [StackString32:StaticRouteResponseProtocol],
        dynamicResponses: [StackString32:DynamicRouteResponseProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol]
    ) {
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.dynamicResponses = dynamicResponses
    }
}
/*
public struct RouterNew : Sendable {
    public let staticResponses:[StackString32:RouteResponseProtocol]

    public init(
        version: String,
        middleware: [any MiddlewareProtocol],
        _ routes: RouteProtocol...
    ) {
        var static_responses:[StackString32:RouteResponseProtocol] = [:]
        let static_middleware:[StaticMiddlewareProtocol] = middleware.compactMap({ $0 as? StaticMiddlewareProtocol })
        let static_routes:[StaticRouteProtocol] = routes.compactMap({ $0 as? StaticRouteProtocol })
        for route in static_routes {
            let response:String = route.response(version: version, middleware: static_middleware)
            var string:String = route.method.rawValue + " /" + route.path + " " + version
            let ss:StackString32 = StackString32(&string)
            static_responses[ss] = RouteResponses.String(response)
        }
        staticResponses = static_responses
    }
}*/

public enum RouterReturnType : String {
    case staticString, uint8Array, uint16Array
    case data
    case unsafeBufferPointer
}

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:String
    public let version:String
    public let headers:[String:String]
    public let body:String

    public init(
        method: HTTPRequest.Method,
        path: String,
        version: String,
        headers: [String:String],
        body: String
    ) {
        self.method = method
        self.path = path
        self.version = version
        self.headers = headers
        self.body = body
    }
}