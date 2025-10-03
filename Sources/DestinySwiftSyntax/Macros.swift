
import DestinyEmbedded

// MARK: Embedded
#if !NonEmbedded
#endif






#if NonEmbedded && canImport(DestinyBlueprint)
import DestinyBlueprint

// MARK: Non embedded





// MARK: #router
/// Default macro to create a `HTTPRouterProtocol`.
///
/// - Parameters:
///   - version: `HTTPVersion` the router responds to. All routes not having a version declared adopt this one.
///   - errorResponder: Error responder when an error is thrown from a route.
///   - dynamicNotFoundResponder: Dynamic responder for requests to unregistered endpoints.
///   - staticNotFoundResponder: Static responder for requests to unregistered endpoints.
///   - middleware: Middleware the router contains. All middleware is handled in the order they are declared (put your most important middleware first).
///   - redirects: Redirects the router contains. Dynamic & Static redirects are automatically created based on this input.
///   - routeGroups: Route groups the router contains.
///   - routes: Routes that the router contains. All routes are subject to the router's static middleware. Only dynamic routes are subject to dynamic middleware.
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


// MARK: #httpMessage
/// A convenience macro to create a complete HTTP Message at compile time.
@freestanding(expression)
public macro httpMessage<T: ExpressibleByStringLiteral>(
    version: HTTPVersion,
    status: HTTPResponseStatus,
    headers: [String:String] = [:],
    body: (any ResponseBodyProtocol)? = nil,
    contentType: String? = nil,
    charset: Charset? = nil
) -> T = #externalMacro(module: "DestinyMacros", type: "HTTPMessage")


// MARK: #declareRouter
/// Declares a struct named `DeclaredRouter` where a compiled router and its optimized data is stored.
/// 
/// - Parameters:
///   - routerSettings: Settings for the router.
///   - perfectHashSettings: Perfect Hash settings to use.
///   - version: `HTTPVersion` the router responds to. All routes not having a version declared adopt this one.
///   - errorResponder: Error responder when an error is thrown from a route.
///   - dynamicNotFoundResponder: Dynamic responder for requests to unregistered endpoints.
///   - staticNotFoundResponder: Static responder for requests to unregistered endpoints.
///   - middleware: Middleware the router contains. All middleware is handled in the order they are declared (put your most important middleware first).
///   - redirects: Redirects the router contains. Dynamic & Static redirects are automatically created based on this input.
///   - routeGroups: Route groups the router contains.
///   - routes: Routes that the router contains. All routes are subject to the router's static middleware. Only dynamic routes are subject to dynamic middleware.
@freestanding(declaration, names: named(DeclaredRouter))
public macro declareRouter(
    routerSettings: RouterSettings = .init(),
    perfectHashSettings: PerfectHashSettings = .init(),

    version: HTTPVersion,
    errorResponder: (any ErrorResponderProtocol)? = nil,
    dynamicNotFoundResponder: (any DynamicRouteResponderProtocol)? = nil,
    staticNotFoundResponder: (any StaticRouteResponderProtocol)? = nil,
    middleware: [any MiddlewareProtocol],
    redirects: [any RedirectionRouteProtocol] = [],
    routeGroups: [any RouteGroupProtocol] = [],
    _ routes: any RouteProtocol...
) = #externalMacro(module: "DestinyMacros", type: "Router")

#endif