
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
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        guard let responder = try responder(for: &request) else { return false }
        try router.respond(socket: socket, request: &request, responder: responder, completionHandler: completionHandler)
        return true
    }

    package func responder(for request: inout HTTPRequest) throws(ResponderError) -> (any DynamicRouteResponderProtocol)? {
        let requestStartLine:SIMD64<UInt8>
        do throws(SocketError) {
            requestStartLine = try request.startLine()
        } catch {
            throw .socketError(error)
        }
        if let responder = parameterless[requestStartLine] {
            return responder
        }
        let pathCount:Int
        do throws(SocketError) {
            pathCount = try request.pathCount()
        } catch {
            throw .socketError(error)
        }
        guard pathCount < parameterized.endIndex else { return try catchallResponder(for: &request) }
        let responders = parameterized[pathCount]
        loop: for responder in responders {
            for i in 0..<pathCount {
                let path = responder.pathComponent(at: i)
                if !path.isParameter {
                    let pathAtIndex:String
                    do throws(SocketError) {
                        pathAtIndex = try request.path(at: i)
                    } catch {
                        throw .socketError(error)
                    }
                    if path.value != pathAtIndex {
                        continue loop
                    }
                }
            }
            return responder
        }
        return try catchallResponder(for: &request)
    }

    func catchallResponder(for request: inout HTTPRequest) throws(ResponderError) -> (any DynamicRouteResponderProtocol)? {
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
                    let pathAtIndex:String
                    do throws(SocketError) {
                        pathAtIndex = try request.path(at: componentIndex)
                    } catch {
                        throw .socketError(error)
                    }
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