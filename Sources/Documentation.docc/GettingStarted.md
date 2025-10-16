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
HTTPDateFormat.load(logger: Logger(label: "destiny.application"))

// run server
try await server.run()
```

### OpenAPI
Destiny doesn't support OpenAPI yet. Once it does, you would be able to automatically generate a working server and router using OpenAPI documents without knowing or understanding how Destiny works.

## Tutorials
No tutorials available at this time.

## See Also
- [Embedded](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Embedded.md)
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Middleware](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Middleware.md)
- [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkIOHandler.md)
- [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Request](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Request.md)
- [Route Path Components](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutePathComponents.md)
- [Routing Hierarchy](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutingHierarchy.md)
- [Router](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Router.md)
- [Server](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Server.md)