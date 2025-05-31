# Destiny

<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.2+-F05138?style=&logo=swift" alt="Requires at least Swift 6.2"></a> <img src="https://img.shields.io/badge/Platforms-Any-gold"> <a href="https://discord.com/invite/VyuFQUpcUz"><img src="https://img.shields.io/badge/Chat-Discord-7289DA?style=&logo=discord"></a> <a href="https://github.com/RandomHashTags/destiny/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue" alt="Apache 2.0 License"></a>

Destiny is a standalone lightweight web server that makes use of the latest Swift features (concurrency, macros, noncopyable types, parameter packs, spans) to push performance to the absolute limits of the Swift Language, and designed to be easy to use while using the minimum amount of dependencies.

It provides a router (which is used via a Swift Macro) that accepts router groups, redirects, middleware and routes for processing requests.

Features like TLS/SSL, Web Sockets and embedded support are coming soon.

We provide a blueprint library, `DestinyBlueprint`, that lays out the API of Destiny's inner workings to perform optimally, empowering the developer to determine the data structures and types used (if you don't use the default implementations from `DestinyDefaults`).

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
- [x] Compression <b>(Dec 24, 2024 | see [Swift Compression](https://github.com/RandomHashTags/swift-compression))</b>
- [x] Hybrid Routes <b>(Dec 24, 2024 | see [ConditionalRouteResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyBlueprint/responders/ConditionalRouteResponderProtocol.swift))</b>
- [x] Router Groups <b>(Dec 27, 2024)</b>
- [x] Error Middleware <b>(Dec 29, 2024 | see [ErrorResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyBlueprint/responders/ErrorResponderProtocol.swift))</b>
- [x] Commands <b>(Dec 31, 2024)</b>
- [x] Case insensitive routes <b>(Feb 19, 2025 | dynamic routes need a little more work)</b>
- [x] Routes with wildcards <b>(Feb 19, 2025)</b>
- [x] Better handling of clients to unlock more throughput <b>(Feb 23, 2025)</b>

### WIP

- [ ] Metric Middleware
- [ ] DocC Documentation and tutorials
- [ ] Unit testing
- [ ] SIMD processing for better performance
- [ ] File Middleware
- [ ] Rate Limit Middleware
- [ ] Optimal Memory Layout for stored objects
- [ ] Cookies

### TODO

- [ ] Cache Middleware
- [ ] Route queries
- [ ] Response/data streaming
- [ ] Data Validation (form, POST, etc)
- [ ] Authentication
- [ ] TLS/SSL
- [ ] Web Sockets
- [ ] Native load balancing & clustering
- [ ] Support custom middleware & routes in default `#router`
- [ ] Support third-party macro expansions in `#router`
- [ ] Embedded support

## Getting started

coming soon...

### Command Line Arguments

Command Line Arguments are prefixed using double hyphens. Command Line Argument aliases are prefixed using a single hyphen.

<details>

<summary>hostname</summary>

Assign the hostname of the server.

- Aliases: `h`
- Usage: `--hostname <hostname>`

</details>

<details>

<summary>port</summary>

Assigns the port of the server.

- Aliases: `p`
- Usage: `--port <port>`

</details>

<details>

<summary>backlog</summary>

Assigns the maximum pending connections the server can queue.

- Aliases: `b`
- Usage: `--backlog <max pending connections>`

</details>

<details>

<summary>reuseaddress</summary>

Allows the server to reuse the address if its in a TIME_WAIT state, avoiding "address already in use" errors when restarting quickly.

- Aliases: `ra`
- Usage: `--reuseaddress <true | false>`

</details>

<details>

<summary>reuseport</summary>

Allows multiple processes to bind to the same port, avoiding contention on a single socket, while enabling load balancing at the kernel level.

- Aliases: `rp`
- Usage: `--reuseport <true | false>`

</details>

<details>

<summary>tcpnodelay</summary>

Disables Nagle's algorithm, which buffers small packets before sending them, to improve latency for real-time applications.

- Aliases: `tcpnd`
- Usage: `--tcpnodelay <true | false>`

</details>

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

Depends on how much dynamic content you add, but initial testing compared to a Static response cost only a few microseconds more (~10-50). I am actively researching and testing improvements.

### Conclusion

This library is the clear leader in reliability, performance and efficiency. Static content offer the best performance, while dynamic content still tops the charts.

## Contributing

Create a PR.