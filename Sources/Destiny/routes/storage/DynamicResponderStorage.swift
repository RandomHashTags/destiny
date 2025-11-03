
#if DynamicResponderStorage

import UnwrapArithmeticOperators

/// Default mutable storage that handles dynamic routes.
public final class DynamicResponderStorage: @unchecked Sendable {
    /// Dynamic routes with no special handling of its path.
    public var parameterless:[SIMD64<UInt8>:any DynamicRouteResponderProtocol]

    /// Dynamic routes with at least one parameter wildcard.
    public var parameterized:[[any DynamicRouteResponderProtocol]]

    /// Dynamic routes with at least one catchall wildcard.
    public var catchall:[any DynamicRouteResponderProtocol]

    public init(
        parameterless: [SIMD64<UInt8>:any DynamicRouteResponderProtocol] = [:],
        parameterized: [[any DynamicRouteResponderProtocol]] = [],
        catchall: [any DynamicRouteResponderProtocol] = []
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
        self.catchall = catchall
    }
}

// MARK: Respond
extension DynamicResponderStorage {
    public func respond(
        provider: some SocketProvider, 
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) -> Bool {
        guard let responder = try responder(for: &request) else { return false }
        try router.respond(provider: provider, request: &request, responder: responder)
        return true
    }

    package func responder(for request: inout HTTPRequest) throws(DestinyError) -> (any DynamicRouteResponderProtocol)? {
        let requestStartLine = try request.startLine()
        if let responder = parameterless[requestStartLine] {
            return responder
        }
        let pathCount = try request.pathCount()
        guard pathCount < parameterized.endIndex else { return try catchallResponder(for: &request) }
        let responders = parameterized[pathCount]
        loop: for responder in responders {
            for i in 0..<pathCount {
                let path = responder.pathComponent(at: i)
                if !path.isParameter {
                    let pathAtIndex = try request.path(at: i)
                    if path.value != pathAtIndex {
                        continue loop
                    }
                }
            }
            return responder
        }
        return try catchallResponder(for: &request)
    }

    func catchallResponder(for request: inout HTTPRequest) throws(DestinyError) -> (any DynamicRouteResponderProtocol)? {
        var responderIndex = 0
        loop: while responderIndex < catchall.count {
            let responder = catchall[responderIndex]
            let componentsCount = responder.pathComponentsCount
            var componentIndex = 0
            while componentIndex < componentsCount {
                let component = responder.pathComponent(at: componentIndex)
                if component == .catchall {
                    return responder
                } else if !component.isParameter {
                    let pathAtIndex = try request.path(at: componentIndex)
                    if component.value != pathAtIndex {
                        responderIndex +=! 1
                        continue loop
                    }
                }
                componentIndex +=! 1
            }
            responderIndex +=! 1
        }
        return nil
    }
}

// MARK: Register
extension DynamicResponderStorage {
    /// Registers a dynamic route responder to the given route path.
    public func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    ) {
        if route.pathContainsParameters {
            var string = route.startLine()
            let buffer = SIMD64<UInt8>(&string)
            if override || parameterless[buffer] == nil {
                parameterless[buffer] = responder
            } else {
                // TODO: throw error
            }
        } else {
            let pathCount = route.pathCount
            if parameterized.count <= pathCount {
                for _ in parameterized.count...pathCount {
                    parameterized.append([])
                }
            }
            parameterized[pathCount].append(responder)
        }
    }
}

#if Protocols

extension DynamicResponderStorage: ResponderStorageProtocol {}

#endif

#endif