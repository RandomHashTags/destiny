# Destiny Routing Hierarchy

This document explains the default steps taken, in sequential order, to route an incoming network request for the Destiny networking framework.

All the steps can be viewed if you expand the Swift Macros. You don't need to jump through documentation to get a physical/mental model of the steps taken.

## Table of Contents
- [Server](#server)
- [Router](#router)
  - [Sub-router](#sub-router)
- [See Also](#see-also)

## Server

All network routing begins when you boot a Server.

The only step executed when an incoming network request is accepted by the [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkIOHandler.md) is passing the file descriptor to the Server's [Router](#router).

## Router

The default router that is expanded by the macros has up-to 3 sub-routers (listed by priority):
1. A router that is `~Copyable` for maximum performance and efficiency
2. A router that is `Copyable` for responses that can't be noncopyable (trading minor performance for major functionality)
3. A router that can register middleware, routes and route groups at runtime (sacrificing major performance for major functionality)

The following steps are executed when a file descriptor is passed to a Router:

1. Load the bare minimum data from the socket into an `HTTPRequest` for optimal management
    - if an error occurs during loading this data: close the file descriptor and log as a warning
2. If any error occurs trying to respond from a sub-router: try sending an "error" response from the sub-routers
    - If no sub-router successfully sends an "error" response: close the file descriptor and log as an error
3. Try sending a response from the sub-routers
4. If no sub-router successfully responds: try sending a "not found" response from the sub-routers
5. If no sub-router successfully sends a "not found" response: close the file descriptor and log as a warning


### Sub-router

Default routing for a sub-router is handled by route responder storages.

Route responder storages try to respond to a request in this priority:

1. perfect hash case-sensitive responder
    - case-sensitive routes where a perfect hash could be generated for
2. perfect hash case-insensitive responder
    - case-insensitive routes where a perfect hash could be generated for
3. static case-sensitive responder
    - remaining case-sensitive static routes
4. static case-insensitive responder
    - remaining case-insensitive static routes
5. dynamic case-sensitive responder
    - remaining case-sensitive dynamic routes
6. dynamic case-insensitive responder
    - remaining case-insensitive dynamic routes


## See Also
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Middleware](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Middleware.md)
- [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkIOHandler.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Request](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Request.md)
- [Route Path Components](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutePathComponents.md)