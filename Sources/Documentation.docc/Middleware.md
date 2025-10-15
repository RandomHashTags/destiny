# Destiny Middleware

## Table of Contents

- [Overview](#overview)
- [Behavior](#behavior)
- [See Also](#see-also)

## Overview

Middleware can be used to edit http requests and responses.

Destiny splits middleware into 2 different kinds of Middleware, Static and Dynamic, which have different performance and functionality characteristics when used, especially when provided in macros.

## Behavior

### Static

"Static" middleware, when normally provided in a macro, does all its editing to requests and responses at compile time for maximum performance and efficiency.

### Dynamic

"Dynamic" middleware edits requests and responses only when handling a request and response.

## See Also
- [Error Handling](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/ErrorHandling.md)
- [Macros](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Macros.md)
- [Performance](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Performance.md)
- [Router](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/Router.md)
- [Routing Hierarchy](https://github.com/RandomHashTags/destiny/tree/main/Sources/Documentation.docc/RoutingHierarchy.md)