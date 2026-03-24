# Destiny Network IO Handler

Destiny chooses the optimal networking io system based on the compilation machine and enabled package traits.

## Handlers
Destiny's networking i/o handlers are:
- Epoll (**Linux only**)
- Liburing (**Linux only**; not yet supported)
- kqueue (**Darwin only**; not yet supported)
- Swift Concurrency (fallback)

## See Also
- [Error Handling](./ErrorHandling.md)
- [Package Traits](./PackageTraits.md)
- [Performance](./Performance.md)
- [Server](./Server.md)