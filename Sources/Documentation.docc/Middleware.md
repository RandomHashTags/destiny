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
- [Error Handling](./ErrorHandling.md)
- [Macros](./Macros.md)
- [Performance](./Performance.md)
- [Router](./Router.md)
- [Routing Hierarchy](./RoutingHierarchy.md)