# Destiny
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=&logo=swift" alt="Requires at least Swift 5.9"></a> <img src="https://img.shields.io/badge/Platforms-Any-gold"> <a href="https://discord.com/invite/VyuFQUpcUz"><img src="https://img.shields.io/badge/Chat-Discord-7289DA?style=&logo=discord"></a> <a href="https://github.com/RandomHashTags/destiny/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue" alt="Apache 2.0 License"></a>

Destiny is a standalone lightweight web server that makes use of the latest Swift features to push performance to the absolute limits of the Swift Language, and designed to require the minimum amount of dependencies.

It provides middleware and routers, which are written using Swift Macros, for processing requests.

Features like native compression, CORS, embedded support, TLS, Web Sockets, and HTTP2 are coming soon.

## Getting started
coming soon...

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