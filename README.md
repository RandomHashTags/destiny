# Destiny

<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=&logo=swift" alt="Requires at least Swift 5.9"></a> <img src="https://img.shields.io/badge/Platforms-Any-gold"> <a href="https://discord.com/invite/VyuFQUpcUz"><img src="https://img.shields.io/badge/Chat-Discord-7289DA?style=&logo=discord"></a> <a href="https://github.com/RandomHashTags/destiny/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue" alt="Apache 2.0 License"></a>

Destiny is a standalone lightweight web server that makes use of the latest Swift features to push performance to the absolute limits of the Swift Language, and designed to require the minimum amount of dependencies.

It provides a router (which is used via a Swift Macro) that accepts router groups, redirects, middleware and routes for processing requests.

Features like TLS/SSL, Web Sockets and embedded support are coming soon.

## Roadmap

- [x] Custom hostname and port <b>(Nov 8, 2024)</b>
- [x] Middleware and Routes <b>(Nov 8, 2024)</b>
- [x] Register middleware/routes after starting server <b>(Nov 8, 2024)</b>
- [x] Support multiple data representations <b>(Nov 8, 2024)</b>
- [x] Routes with custom parameters <b>(Nov 8, 2024)</b>
- [x] Configure settings via Command Line Arguments <b>(Dec 11, 2024)</b>
- [x] Compression <b>(Dec 24, 2024 | see [Swift Compression](https://github.com/RandomHashTags/swift-compression))</b>
- [x] Hybrid Routes <b>(Dec 24, 2024 | see [ConditionalRouteResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyUtilities/routes/responders/ConditionalRouteResponderProtocol.swift))</b>
- [ ] CORS <b>(Dynamic CORS implemented Dec 9, 2024)</b>
- [ ] Redirects <b>(Static Redirects implemented Dec 11, 2024)</b>
- [ ] Router Groups
- [ ] Metric Middleware
- [ ] Queries
- [ ] Commands
- [ ] Data Validation (form, POST, etc)
- [ ] Authentication
- [ ] TLS/SSL
- [ ] Web Sockets
- [ ] SIMD processing for headers
- [ ] Response/data streaming
- [ ] Support custom middleware & routes in default `#router`
- [ ] Support third-party macro expansions in `#router`
- [ ] Unit testing middleware/routes/requests
- [ ] Better handling of clients to unlock more throughput
- [ ] CSS & JavaScript minification (separate repo?)
- [ ] Swift-APNS (separate repo?)
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

<summary>maxpendingconnections</summary>

Assigns the maximum pending connections the server can queue.

- Aliases: `mpc`
- Usage: `--maxpendingconnections <max pending connections>`

</details>


## Benchmarks

- Libraries tested
  - [RandomHashTags/destiny](https://github.com/RandomHashTags/destiny) v0.1.0 (this library)
  - [hummingbird-project/hummingbird](https://github.com/hummingbird-project/hummingbird) v2.1.0
  - [vapor/vapor](https://github.com/vapor/vapor) v4.106.0

### Static

Initial testing of a basic HTML response shows that this library has the lowest server latency and most consistent timings **when serving the same content**.

### Dynamic

Depends on how much dynamic content you add, but initial testing compared to a Static response cost only a few microseconds more (~10-50). I am actively researching and testing improvements.

### Conclusion

This library is the clear leader in reliability, performance and efficiency. Static content offer the best performance, while dynamic content still tops the charts.

## Contributing

Create a PR.