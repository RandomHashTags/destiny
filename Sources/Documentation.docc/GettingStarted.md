# Getting Started with Destiny

## Table of Contents
- [Requirements](#requirements)
- [Quickstart](#quickstart)
  - [Manual](#manual)
  - [OpenAPI](#openapi)
- [Tutorials](#tutorials)
- [See Also](#see-also)

## Requirements
- minimum of Swift 6.2

## Quickstart

### Manual

#### Step 1
Create a Router using a macro (`#declareRouter` or `#router`):

```swift
package struct DestinyStorage {
    #declareRouter(
        routerSettings: .init(
            visibility: .package, // make the router `package` accessible
        ),
        version: .v1_1, // indicates the router uses HTTP/1.1
        middleware: [
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesContentTypes: ["text/html"],
                appliesStatus: 200, // ok
                appliesHeaders: [
                    "server":"destiny",
                    "connection":"close"
                ]
            )
        ],
        Route.get(
            path: ["hello"],
            contentType: "text/html",
            body: NonCopyableStaticStringWithDateHeader(#"Hello World!"#)
        )
    )
}
```

#### Step 2
Create and run a Server:

```swift
// create server
let server = NonCopyableHTTPServer<DestinyStorage.DeclaredRouter.CompiledHTTPRouter, HTTPSocket>(
    port: 8080,
    router: DestinyStorage.DeclaredRouter.router,
    logger: Logger(label: "destiny.http.server")
)

// precompute and auto-update the "date" header
HTTPDateFormat.load(logger: Logger(label: "destiny.http.dateformat"))

// run server
try await server.run()
```

### OpenAPI
Destiny doesn't support OpenAPI yet. Once it does, you would be able to automatically generate a working server and router using OpenAPI documents without knowing or understanding how Destiny works.

## Tutorials
No tutorials available at this time.

## See Also
- [Embedded](./Embedded.md)
- [Error Handling](./ErrorHandling.md)
- [Logging, Metrics and Tracing](./LoggingMetricsTracing.md)
- [Macros](./Macros.md)
- [Middleware](./Middleware.md)
- [Network IO Handler](./NetworkIOHandler.md)
- [Package Traits](./PackageTraits.md)
- [Performance](./Performance.md)
- [Request](./Request.md)
- [Route Path Components](./RoutePathComponents.md)
- [Routing Hierarchy](./RoutingHierarchy.md)
- [Router](./Router.md)
- [Server](./Server.md)