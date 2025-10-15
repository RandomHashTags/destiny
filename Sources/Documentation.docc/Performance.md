# Destiny Performance

This document explains the performance of Destiny to achieve maximum performance, and why.

## Table of Contents
- [Techniques](#techniques)
- [Limitations](#limitations)
- [Benchmarks](#benchmarks)
- [See Also](#see-also)

## Techniques

### Actor avoidance
Swift Actors mitigate data races by sacrificing performance. Destiny doesn't use them because it uses better state management and data structures to avoid data races.

Destiny uses the Swift 6 Language Mode by default so data races are guaranteed to be avoided at compile time.

### Annotations

Destiny utilizes certain annotations to improve performance.
- `@inlinable`
- `@inline(__always)`
- `@_marker`

### CodeGen
For tedious work and easier development.

### Concurrency
Destiny utilizes Swift Concurrency to maximize multi-core performance and support non-blocking operations.

### Generics
Only where opaque types aren't applicable to avoid dynamic dispatch, existentials and boxing (especially in hot paths).

### InlineArray
Implemented in Swift 6.2, Destiny utilizes `InlineArray` because it is a stack-based array value type that offers major performance wins over heap-based arrays. This is the main reason why the minimum required Swift version to use Destiny is 6.2.

### Macros
Swift Macros are a powerful compile time feature. Destiny utilizes them to abstract manual creation and maintenance of its middleware, servers, routers, routes, and route groups for optimal convenience, productivity and performance.

- All middleware, redirects, routes, and route groups generate optimal data structures and logic during the expansion of a `#router`
  - tries enabling Perfect Hashing for routes for optimal routing performance

### Minimal Dependencies
To reduce binary size, simplify development and give full control over implementation details to the developer.

- no Foundation (by default)
- no SwiftNIO

### Minimal Protocols
Destiny was originally designed to abstract the underlying implementations to support third-party data structures and state management. `DestinyBlueprint` is the module that enables plug and play of any implementation as long as it conforms to the right protocols.

Diving deeper into performance and binary size optimizations, Destiny is moving away from this abstraction since the abstraction required to maximize performance while supporting custom implementations is overly restrictive requiring duplicating protocols and code with minor differences. Destiny would like to adopt `@_marker` on its protocols throughout `DestinyBlueprint` to fully support custom implementations again but the annotation doesn't support adding protocol requirements (and its not a fully stable/supported annotation).

### Module Abstractions
To simplify and allow more control over development implementations.

### Network IO
Destiny utilizes highly efficient networking systems to perform optimally.

See [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkingIOHandler.md).

### Noncopyable Values
Destiny heavily uses noncopyable values and ownership semantics for optimal performance, avoiding common retain/release/ARC traffic that can hurt performance.

### Opaque Types
To avoid dynamic dispatch, existentials and boxing (especially in hot paths).

### Package Traits
Implemented in Swift 6.1, Destiny utilizes Swift Package Traits to enable (or disable) features at the compilation level. This offers optimal control over binary size and expected features, reducing code bloat and improving debuggability.

See [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md) for the full list Destiny supports.

### Parameter Packs
For compile-time array optimizations, reducing heap allocations and dynamic dispatch.

### Perfect Route Hashing
Unlocks blazingly fast routing.

### Performance Profiling
Destiny was heavily designed by utilizing `perf` and `nm` to determine best data structures and techniques for optimal performance and binary size without sacrificing functionality.

### Small Binary
A small binary is an overall indication of how well a project is developed. Destiny is built in such a way to eliminate bloat and allow complete control over its underlying features which make maintaining, debugging, and deploying hassle-free.

Swift [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md) greatly help in this area.

### Swift 6 Language Mode
Destiny uses the Swift 6 Language Mode by default, enabling compile time data race safety.

### Structs by default
Structs have way better performance characteristics than classes, which is why they are the default even if they require more care when handling. Destiny's structs are also designed to use as little memory as possible (optimally aligning types).

### Typed Throws
Destiny utilizes typed throws to avoid heap allocations and reduced performance associated with regular, existential errors and throws.

### Unwrap Arithmetic Operators
Where applicable, to reduce arithmetic overhead (Swift's default arithmetic safety features).

Can be disabled by removing the package traits `UnwrapAddition`, `UnwrapSubtraction` and `UnwrapArithmetic`.

### Yielding Accessors
`_read` and `_modify` accessors reduce overhead.


### TODO
List of techniques Destiny wants to incorporate to push performance even further, not strictly Swift related.

- file descriptor pool
- connection pool
- optionally batch responses
- kqueue support
- io_uring support

## Limitations

Areas that Swift needs more development/support to unlock more abstraction/performance at the language level.

- `~Copyable` types in parameter packs (current `Copyable` requirement causes retain/release and ARC traffic)
- `~Copyable` types not being allowed as a `typealias` or `associatedtype` (as a protocol requirement)
- `~Copyable` types not being allowed in tuples
- `Async[Throwing]Stream` not supporting typed throws
- `Async[Throwing]Stream` not supporting `~Copyable` values
- Parameter Pack same-element requirements not being supported ("yet")
- `@_marker` protocols not allowing requirements

## Benchmarks
- Libraries tested
  - [RandomHashTags/destiny](https://github.com/RandomHashTags/destiny) v0.2.0 (this library)
  - [hummingbird-project/hummingbird](https://github.com/hummingbird-project/hummingbird) v2.11.1
  - [vapor/vapor](https://github.com/vapor/vapor) v4.114.1

### Static

Initial testing of a basic HTML response shows this library has the lowest server latency, highest throughput and most consistent timings **when serving the same content**.

### Dynamic

Depends on how much dynamic content you add; initial testing compared to a Static response performs about the same but usually costs a few microseconds more (~10-50).

### Conclusion

This library is a clear leader in reliability, performance and efficiency. Performance metrics for static **and** dynamic content are better than or comparable to the best networking libraries available (regardless of programming language).



## See Also
- [Embedded](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Embedded.md)
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Middleware](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Middleware.md)
- [Network IO Handler](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/NetworkIOHandler.md)
- [Router](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Router.md)
- [Routing Hierarchy](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutingHierarchy.md)
- [Server](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Server.md)