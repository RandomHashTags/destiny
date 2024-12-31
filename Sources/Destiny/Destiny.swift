//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

@_exported import DestinyDefaults
@_exported import DestinyUtilities
import HTTPTypes
import Logging
import ServiceLifecycle
import SwiftCompression

/// The default macro to create a default `Router`.
///
/// - Parameters:
///   - version: The `HTTPVersion` this router responds to. All routes not having a version declared adopt this one.
///   - errorResponder: The error responder when an error is thrown from a route.
///   - dynamicNotFoundResponder: The dynamic responder for requests to unregistered endpoints.
///   - staticNotFoundResponder: The static responder for requests to unregistered endpoints.
///   - supportedCompressionAlgorithms: The supported compression algorithms. All routes will be updated to support these.
///   - redirects: The redirects this router contains. Dynamic & Static redirects are automatically created based on this input.
///   - middleware: The middleware this router contains. All middleware is handled in the order they are declared (put your most important middleware first).
///   - redirects: The redirects this router contains.
///   - routerGroups: The router groups this router contains.
///   - routes: The routes that this router contains. All routes are subject to this router's static middleware. Only dynamic routes are subject to dynamic middleware.
@freestanding(expression)
public macro router(
    version: HTTPVersion,
    errorResponder: ErrorResponderProtocol? = nil,
    dynamicNotFoundResponder: DynamicRouteResponderProtocol? = nil,
    staticNotFoundResponder: StaticRouteResponderProtocol? = nil,
    supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
    middleware: [MiddlewareProtocol],
    redirects: [HTTPRequest.Method : [HTTPResponse.Status : [String:String]]] = [:],
    routerGroups: [RouterGroupProtocol] = [],
    _ routes: RouteProtocol...
) -> Router = #externalMacro(module: "DestinyMacros", type: "Router")


/// A convenience macro to create a complete HTTP Response at compile time.
@freestanding(expression)
public macro httpMessage<T: ExpressibleByStringLiteral>(
    version: HTTPVersion,
    status: HTTPResponse.Status,
    headers: [String:String] = [:],
    result: RouteResult? = nil,
    contentType: HTTPMediaType? = nil,
    charset: String? = nil
) -> T = #externalMacro(module: "DestinyMacros", type: "HTTPMessage")

// MARK: Application
public struct Application : Service {
    public static private(set) var shared:Application! = nil

    public let server:ServerProtocol
    public let services:[Service]
    public let logger:Logger

    public init(
        server: ServerProtocol,
        services: [Service] = [],
        logger: Logger
    ) {
        self.server = server
        var services:[Service] = services
        services.insert(server, at: 0)
        self.services = services
        self.logger = logger
        Self.shared = self
    }
    public func run() async throws {
        let service_group:ServiceGroup = ServiceGroup(configuration: .init(services: services, logger: logger))
        try await service_group.run()
    }
}