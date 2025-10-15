# Destiny Network IO Handler

Destiny chooses the optimal networking io system based on the compilation machine and enabled package traits.

## Handlers
Destiny's networking i/o handlers are:
- Epoll (**Linux only**)
- Liburing (**Linux only**; not yet supported)
- kqueue (**Darwin only**; not yet supported)
- Swift Concurrency (fallback)

## See Also
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Server](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Server.md)