# Error Handling

Destiny uses typed throws out-of-the-box for optimal performance. The only places Destiny doesn't use typed throws are where they are unsupported in the standard library and at the language level (`AsyncThrowingStream` and certain closures).

## Typed Throws

Destiny uses a single `DestinyError` enum to optimally manage errors.

## See Also
- [Logging, Metrics and Tracing](./LoggingMetricsTracing.md)
- [Performance](./Performance.md)