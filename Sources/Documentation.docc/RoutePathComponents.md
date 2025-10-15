# Destiny Route Path Components

## Table of Contents
- [Wildcards](#wildcards)
  - [Catchall](#catchall)
  - [Parameters](#parameters)
  - [Queries](#queries)
- [See Also](#see-also)

## Wildcards

### Catchall

Matches all path components where the catchall component begins and all trailing path components. All matched components are treated as parameters.

- Symbols: `**`

Access the parameters by getting the index of the parameter you want.

#### Example

We have the following route paths (identical in practice):
```
GET /api/**/ping
GET /api/**/user/profile
GET /api/**/user/details
GET /api/**/data
```

Example requests are as follows:
```
GET /api/v1/ping
GET /api/v2/user/profile
GET /api/any/user/details
GET /api/component/data
```

And their parameters are as follows:
```swift
["v1", "ping"]
["v2", "user", "profile"]
["any", "user", "details"]
["component", "data"]
```

### Parameters

- Symbols: `*`, `:parameterName`
- Supports partial matching

Access the parameters by getting the index of the parameter you want.

#### Example

We have the following route paths:
```
GET /api/*/data
GET /api/:version/data
```

Example requests are as follows:
```
GET /api/v1/data
GET /api/v2/data
GET /api/any/data
GET /api/component/data
```

And their parameters are as follows:
```swift
["v1"]
["v2"]
["any"]
["component"]
```

##### Partial Matching

We have the following route paths:
```
GET /api/*.jpg
GET /api/*.png
```

Example requests are as follows:
```
GET /api/small.jpg
GET /api/big.jpg
GET /api/small.png
GET /api/big.png
```

And their parameters are as follows:
```swift
["small"]
["big"]
["small"]
["big"]
```

### Queries

Not yet supported

## See Also
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Logging, Metrics and Tracing](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/LoggingMetricsTracing.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Request](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Request.md)
- [Router](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Router.md)
- [Routing Hierarchy](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutingHierarchy.md)