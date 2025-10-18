# Destiny Package Traits

This document lists all the available package traits for Destiny.

## Table of Contents
- [Functionality](#functionality)
- [Annotations](#annotations)
- [Embedded](#embedded)
- [Third-party](#third-party)
- [See Also](#see-also)

## Functionality

List of package traits that toggle features in Destiny.

### CORS
Enables cross-origin resource sharing functionality.

### HTTPCookie
Enables the default `HTTPCookie` implementation and convenient code associated with it.

### MutableRouter
Enables functionality that registers data to a Router at runtime.

### NonEmbedded
Enables functionality suitable for non-embedded devices (mainly existentials).

### RateLimits
Enables default rate limiting functionality.

### RequestBody
Enables functionality to access a request's body.
- Enables traits: `RequestHeaders`

### RequestBodyStream
Enables functionality that can stream a request's body.
- Enables traits: `RequestBody`

### RequestHeaders
Enables functionality to access a request's headers.

## Annotations

List of package traits that enable annotations where annotated.

### Inlinable
Enables the `@inlinable` annotation where annotated.

### InlineAlways
Enables the `@inline(__always)` annotation where annotated.


## Embedded

List of package traits that enable functionality suitable for embedded.

### GenericHTTPMessage
Enables an HTTP Message implementation utilizing generics, avoiding existentials.

### GenericStaticRoute
Enables a `StaticRoute` implementation utilizing generics, avoiding existentials.

### GenericDynamicRoute
Enables a `DynamicRoute` implementation utilizing generics, avoiding existentials.

### GenericDynamicResponse
Enables a DynamicResponse implementation utilizing generics, avoiding existentials.
- Enables traits: `GenericHTTPMessage`

### GenericRouteGroup
Enables a `RouteGroup` implementation utilizing generics, avoiding existentials.

### Generics
Enables all Generic package traits.
- Enables traits: `GenericHTTPMessage`, `GenericStaticRoute`, `GenericDynamicRoute`, `GenericDynamicResponse`, `GenericRouteGroup`


## Third-party

List of package traits that add third-party convenience/support.

### Epoll
Enables Epoll functionality (**Linux only**).

### Liburing
Enables Liburing functionality (**Linux only**).

### Logging
Enables `swift-log` functionality.

### MediaTypes
Enables `swift-media-types` functionality.

### OpenAPI
Enables functionality to support OpenAPI.

### UnwrapAddition
Enables unchecked overflow addition operators (`+!` and `+=!`), avoiding Swift's default arithmetic behavior (and overhead).

### UnwrapSubtraction
Enables unchecked overflow subtraction operators (`-!` and `-=!`), avoiding Swift's default arithmetic behavior (and overhead).

### UnwrapArithmetic
Enables `UnwrapAddition` and `UnwrapSubtraction` package traits.

## See Also
- [Embedded](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Embedded.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkIOHandler.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Request](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Request.md)
- [Router](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Router.md)
- [Routing Hierarchy](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutingHierarchy.md)
- [Server](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Server.md)