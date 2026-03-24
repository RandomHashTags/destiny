# Destiny Package Traits
This document lists all the available package traits for Destiny.

## Table of Contents
- [Functionality](#functionality)
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


## Embedded
List of package traits that enable functionality suitable for embedded.

### GenericRouteGroup
Enables a `RouteGroup` implementation utilizing generics, avoiding existentials.


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
- [Embedded](./Embedded.md)
- [Logging, Metrics and Tracing](./LoggingMetricsTracing.md)
- [Macros](./Macros.md)
- [Network IO Handler](./NetworkIOHandler.md)
- [Performance](./Performance.md)
- [Request](./Request.md)
- [Router](./Router.md)
- [Routing Hierarchy](./RoutingHierarchy.md)
- [Server](./Server.md)