
import DestinyDefaults
import DestinyEmbedded

@freestanding(declaration, names: named(Server))
public macro httpServer(
    address: String? = nil,
    port: UInt16 = 8080,
    backlog: Int32 = 0,
    routerType: String = "CompiledHTTPRouter",
    reuseAddress: Bool = true,
    reusePort: Bool = true,
    noTCPDelay: Bool = true,
    maxEpollEvents: Int = 64,
    socketType: String = "DestinyDefaults.HTTPSocket",
    onLoad: (() -> Void)? = nil,
    onShutdown: (() -> Void)? = nil
) = #externalMacro(module: "DestinyMacros", type: "Server")

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
    redirects: [StaticRedirectionRoute] = [],
    routeGroups: [any RouteGroupProtocol] = [],
    _ routes: any RouteProtocol...
) -> T = #externalMacro(module: "DestinyMacros", type: "Router")


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
    redirects: [StaticRedirectionRoute] = [],
    routeGroups: [any RouteGroupProtocol] = [],
    _ routes: any RouteProtocol...
) = #externalMacro(module: "DestinyMacros", type: "Router")

#endif