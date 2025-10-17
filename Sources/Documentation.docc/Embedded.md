# Destiny Embedded

Destiny was designed from the ground up for optimal performance. This means it opts-in to many of Swift's performance related features by default (structs, generics, opaque types, typed throws, etc). Many of Swift's performance related features are also supported in Embedded, which makes Destiny easy to work with both modes.

Many of the convenience Destiny offers through macros and routing are lost when building for embedded due to very limited support for existentials. Destiny mitigates this by filling the gaps with generic parameters and opaque types.

You can read about all of Swift Embedded over on the official swift.org [website](https://docs.swift.org/embedded/documentation/embedded/).

## See Also
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Package Traits](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/PackageTraits.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Middleware](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Middleware.md)