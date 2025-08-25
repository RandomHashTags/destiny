
@_exported import Destiny

/// Default macro to create a `HTTPRouter`.
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
///   - routeGroups: The router groups this router contains.
///   - routes: The routes that this router contains. All routes are subject to this router's static middleware. Only dynamic routes are subject to dynamic middleware.
@freestanding(expression)
public macro router<T: HTTPRouterProtocol>(
    version: HTTPVersion,
    errorResponder: (any ErrorResponderProtocol)? = nil,
    dynamicNotFoundResponder: (any DynamicRouteResponderProtocol)? = nil,
    staticNotFoundResponder: (any StaticRouteResponderProtocol)? = nil,
    middleware: [any MiddlewareProtocol],
    redirects: [any RedirectionRouteProtocol] = [],
    routeGroups: [any RouteGroupProtocol] = [],
    _ routes: any RouteProtocol...
) -> T = #externalMacro(module: "DestinyMacros", type: "Router")

/// A convenience macro to create a complete HTTP Message at compile time.
@freestanding(expression)
public macro httpMessage<T: ExpressibleByStringLiteral>(
    version: HTTPVersion,
    status: HTTPResponseStatus,
    headers: [String:String] = [:],
    body: (any ResponseBodyProtocol)? = nil,
    contentType: HTTPMediaType? = nil,
    charset: Charset? = nil
) -> T = #externalMacro(module: "DestinyMacros", type: "HTTPMessage")

/// Declares a struct named `DeclaredRouter` where a compiled router and its optimized data is stored.
@freestanding(declaration, names: named(DeclaredRouter))
public macro declareRouter(
    visibility: RouterVisibility = .internal,
    mutable: Bool = false,
    typeAnnotation: String? = nil,

    version: HTTPVersion,
    errorResponder: (any ErrorResponderProtocol)? = nil,
    dynamicNotFoundResponder: (any DynamicRouteResponderProtocol)? = nil,
    staticNotFoundResponder: (any StaticRouteResponderProtocol)? = nil,
    middleware: [any MiddlewareProtocol],
    redirects: [any RedirectionRouteProtocol] = [],
    routeGroups: [any RouteGroupProtocol] = [],
    _ routes: any RouteProtocol...
) = #externalMacro(module: "DestinyMacros", type: "Router")