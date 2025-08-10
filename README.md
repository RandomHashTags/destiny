# Destiny

<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.2+-F05138?style=&logo=swift" alt="Requires at least Swift 6.2"></a> <img src="https://img.shields.io/badge/Platforms-Any-gold"> <a href="https://discord.com/invite/VyuFQUpcUz"><img src="https://img.shields.io/badge/Chat-Discord-7289DA?style=&logo=discord"></a> <a href="https://github.com/RandomHashTags/destiny/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue" alt="Apache 2.0 License"></a>

Destiny is a standalone lightweight web server that makes use of the latest Swift features to push performance to the limit of the language, and designed to be easy to use while using the minimum amount of dependencies.

It provides a router (which is used via a Swift Macro) that accepts middleware, redirects, routes, and route groups for processing requests.

Features like TLS/SSL, Web Sockets and embedded support are coming soon.

We provide a blueprint library, `DestinyBlueprint`, that lays out the API of Destiny's inner workings to perform optimally, empowering the developer to determine the data structures and types used (if you don't use the default implementations from `DestinyDefaults`).

## Table of Contents

- [Roadmap](#roadmap)
  - [Completed](#completed)
  - [WIP](#wip)
  - [TODO](#todo)
- [Techniques](#techniques)
  - [TODO](#todo-1)
  - [Limitations](#limitations)
- [Getting Started](#getting-started)
  - [Routes](#routes)
    - [Wildcards](#wildcards)
- [Benchmarks](#benchmarks)
  - [Static](#static)
  - [Dynamic](#dynamic)
  - [Conclusion](#conclusion)
- [Contributing](#contributing)
- [Support](#support)
  - [Funding](#funding)

## Roadmap

### Completed

- [x] Custom hostname and port <b>(Nov 8, 2024)</b>
- [x] Middleware and Routes <b>(Nov 8, 2024)</b>
- [x] Register middleware/routes after starting server <b>(Nov 8, 2024)</b>
- [x] Support multiple data representations <b>(Nov 8, 2024)</b>
- [x] Routes with parameters <b>(Nov 8, 2024)</b>
- [x] CORS <b>(Dec 9, 2024 | static CORS needs a little more work)</b>
- [x] Configure settings via Command Line Arguments <b>(Dec 11, 2024)</b>
- [x] Redirects <b>(Dec 11, 2024 | dynamic redirects need a little more work)</b>
- [x] Hybrid Routes <b>(Dec 24, 2024 | see [ConditionalRouteResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyBlueprint/responders/ConditionalRouteResponderProtocol.swift))</b>
- [x] Route Groups <b>(Dec 27, 2024)</b>
- [x] Error Middleware <b>(Dec 29, 2024 | see [ErrorResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyBlueprint/responders/ErrorResponderProtocol.swift))</b>
- [x] Case insensitive routes <b>(Feb 19, 2025 | dynamic routes need a little more work)</b>
- [x] Routes with wildcards <b>(Feb 19, 2025)</b>
- [x] Better handling of clients to unlock more throughput <b>(Feb 23, 2025)</b>
- [x] Response streaming <b>(Aug 2, 2025)</b>
- [x] Typed throws where applicable <b>(Aug 3, 2025)</b>
- [x] Foundation-less <b>(Aug 5, 2025)</b>
- [x] Swift 6 Language Mode <b>(Aug 5, 2025)</b>
- [x] Cookies <b>(Aug 9, 2025)</b>

### WIP

- [ ] Metric Middleware
- [ ] DocC Documentation
- [ ] Unit testing
- [ ] SIMD processing for better performance
- [ ] File Middleware
- [ ] Rate Limit Middleware
- [ ] Optimal Memory Layout for stored objects
- [ ] Route queries
- [ ] Embedded support

### TODO

- [ ] DocC Tutorials
- [ ] Cache Middleware
- [ ] Request body streaming
- [ ] Data Validation (form, POST, etc)
- [ ] Authentication
- [ ] TLS/SSL
- [ ] Web Sockets
- [ ] Native load balancing & clustering
- [ ] Support custom middleware & routes in default `#router`
- [ ] Support third-party macro expansions in `#router`

## Techniques

List of techniques Destiny uses to push performance to the limits of the Swift Language.

<details>

<summary>Structs by default</summary>

To avoid heap allocation and pointer indirection

</details>

<details>

<summary>Noncopyable types</summary>

To avoid retain/release and ARC traffic

</details>

<details>

<summary>@inlinable annotation</summary>

To make sure we inline hot-paths as much as possible

</details>

<details>

<summary>Actor avoidance</summary>

To encourage better state management and data structures

</details>

<details>

<summary>InlineArrays</summary>

To avoid heap allocations (especially in hot-paths)

</details>

<details>

<summary>Concurrency</summary>

To maximize multi-core performance and support non-blocking operations

</details>

<details>

<summary>Macros</summary>

Unlocks compile-time optimizations for middleware, routes and responders

<b>Most compile-time optimizations for optimal runtime performance happens here</b>

</details>

<details>

<summary>Parameter Packs</summary>

For compile-time array optimizations, reducing heap allocations and dynamic dispatch 

</details>

<details>

<summary>Opaque types</summary>

To avoid dynamic dispatch, existentials and boxing (especially in hot-paths)

</details>

<details>

<summary>Generic parameters</summary>

Only where opaque types aren't applicable to avoid dynamic dispatch, existentials and boxing (especially in hot-paths)

</details>

<details>

<summary>Typed throws</summary>

To improve runtime performance and a step closer to support embedded; eliminates heap allocation, metadata and dynamic dispatch for error handling

</details>

<details>

<summary>Swift 6 Language Mode</summary>

To avoid data races by enforcing compile time data race safety

</details>

<details>

<summary>Code Generation</summary>

For tedious work and easier development

</details>

<details>

<summary>Minimal Dependencies</summary>

To reduce binary size and simplify development

- no Foundation
- no SwiftNIO

</details>

<details>

<summary>Module Abstractions</summary>

To simplify and allow more control over development implementations

</details>

<details>

<summary>Benchmarks and performance profiling</summary>

To determine best data structures and techniques for optimal performance without sacrificing functionality

</details>

### TODO

List of techniques Destiny wants to incorporate to push performance even further, not strictly Swift related.

- file descriptor pool
- connection pool
- optionally batch responses
- kqueue support

### Limitations

Areas that Swift needs more development/support to unlock more performance at the language level.

- `~Copyable` types in parameter packs (current `Copyable` requirement causes retain/release and ARC traffic)
- `~Copyable` types not being able to be used as a `typealias` or `associatedtype`

## Getting started

coming soon...

## Routes

### Wildcards

- `*` and `:<param name>` = parameter
- `**` = catchall


## Benchmarks

- Libraries tested
  - [RandomHashTags/destiny](https://github.com/RandomHashTags/destiny) v0.2.0 (this library)
  - [hummingbird-project/hummingbird](https://github.com/hummingbird-project/hummingbird) v2.11.1
  - [vapor/vapor](https://github.com/vapor/vapor) v4.114.1

### Static

Initial testing of a basic HTML response shows that this library has the lowest server latency, highest throughput and most consistent timings **when serving the same content**.

### Dynamic

Depends on how much dynamic content you add, but initial testing compared to a Static response performs about the same, but usually costs a few microseconds more (~10-50). I am actively researching and testing improvements.

### Conclusion

This library is the clear leader in reliability, performance and efficiency. Static content offer the best performance, while dynamic content still tops the charts.

## Contributing

Create a PR.

## Support

You can create a discussion here on GitHub for support or join my Discord server at https://discord.com/invite/VyuFQUpcUz.

### Funding

This project was developed to allow everyone to create better http servers. I develop and maintain many free open-source projects full-time for the benefit of everyone.

You can show your financial appreciation for this project and others by sponsoring us here on GitHub or other ways listed in the [FUNDING.yml](https://github.com/RandomHashTags/destiny/blob/main/.github/FUNDING.yml).