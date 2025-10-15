# Error Handling

Destiny uses typed throws out-of-the-box for optimal performance. The only places Destiny doesn't use typed throws are where they are unsupported in the standard library and at the language level (`AsyncThrowingStream` and certain closures).

## Typed Throws

Here is a list of the typed throws Destiny uses:
- `AnyError`
- `BufferWriteError`
- `EpollError`
- `HTTPCookieError`
- `HTTPMessageError`
- `MiddlewareError`
- `ResponderError`
- `RouterError`
- `ServerError`
- `ServiceError`
- `SocketError`

## See Also
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)