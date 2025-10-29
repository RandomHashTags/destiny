# Destiny

<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.2+-F05138?style=&logo=swift" alt="Requires at least Swift 6.2"></a> <img src="https://img.shields.io/badge/Platforms-Any-gold"> <a href="https://discord.com/invite/VyuFQUpcUz"><img src="https://img.shields.io/badge/Chat-Discord-7289DA?style=&logo=discord"></a> <a href="https://github.com/RandomHashTags/destiny/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue" alt="Apache 2.0 License"></a>

Destiny is a standalone, high-performance and lightweight web server that makes use of the latest Swift features to push performance to the limit of the language, and designed to be easy to use while keeping the binary size small.

It provides a router (which is used via a Swift Macro) that accepts middleware, redirects, routes, and route groups for processing requests.

Features like TLS/SSL, Web Sockets and embedded support are coming soon.

## Table of Contents

- [Roadmap](#roadmap)
  - [Completed](#completed)
  - [WIP](#wip)
  - [TODO](#todo)
- [Documentation](#documentation)
- [Benchmarks](#benchmarks)
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
- [x] Redirects <b>(Dec 11, 2024)</b>
- [x] Route Groups <b>(Dec 27, 2024)</b>
- [x] Error Middleware <b>(Dec 29, 2024 | see [ErrorResponderProtocol](https://github.com/RandomHashTags/destiny/tree/main/Sources/DestinyBlueprint/responders/ErrorResponderProtocol.swift))</b>
- [x] Case insensitive routes <b>(Feb 19, 2025)</b>
- [x] Routes with wildcards <b>(Feb 19, 2025)</b>
- [x] Better handling of clients to unlock more throughput <b>(Feb 23, 2025)</b>
- [x] Response streaming <b>(Aug 2, 2025)</b>
- [x] Typed throws where applicable <b>(Aug 3, 2025)</b>
- [x] Foundation-less <b>(Aug 5, 2025)</b>
- [x] Swift 6 Language Mode <b>(Aug 5, 2025)</b>
- [x] Cookies <b>(Aug 9, 2025)</b>
- [x] Header parsing <b>(Sep 9, 2025)</b>
- [x] Request body streaming <b>(Sep 10, 2025)</b>

### WIP

- [ ] DocC Documentation
- [ ] DocC Tutorials
- [ ] Route partial matching (via Regex or something else)
- [ ] Unit testing
- [ ] Rate Limits
- [ ] Route queries
- [ ] Metric Middleware
- [ ] File Middleware
- [ ] HTTP Pipelining
- [ ] Embedded support

### TODO

- [ ] Allow more than 64 bytes as the compared request line
- [ ] Cache Middleware
- [ ] Data Validation (form, POST, etc)
- [ ] Authentication
- [ ] Compression support
- [ ] OpenAPI support
- [ ] Tracing support
- [ ] TLS/SSL
- [ ] Web Sockets
- [ ] Native load balancing & clustering
- [ ] Support custom middleware & routes in the macro
- [ ] Support third-party macro expansions in the macro

## Documentation

See [Documentation](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Index.md)

## Benchmarks

See [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)

## Contributing

Create a PR.

## Support

You can create a discussion here on GitHub for support or join my Discord server at https://discord.com/invite/VyuFQUpcUz.

### Funding

This project was developed to allow everyone to create better http servers. I develop and maintain many free open-source projects full-time for the benefit of everyone.

You can show your financial appreciation for this project and others by sponsoring us here on GitHub or other ways listed in the [FUNDING.yml](https://github.com/RandomHashTags/destiny/blob/main/.github/FUNDING.yml).