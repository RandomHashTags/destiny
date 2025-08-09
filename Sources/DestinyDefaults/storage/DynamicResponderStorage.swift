
import DestinyBlueprint

/// Default mutable storage that handles dynamic routes.
public final class DynamicResponderStorage: MutableDynamicResponderStorageProtocol, @unchecked Sendable {
    /// The dynamic routes without parameters.
    public var parameterless:[DestinyRoutePathType:any DynamicRouteResponderProtocol]

    /// The dynamic routes with parameters.
    public var parameterized:[[any DynamicRouteResponderProtocol]]

    public var catchall:[any DynamicRouteResponderProtocol]

    public init(
        parameterless: [DestinyRoutePathType:any DynamicRouteResponderProtocol] = [:],
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
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        guard let responder = responder(for: &request) else { return false }
        try await router.respondDynamically(socket: socket, request: &request, responder: responder)
        return true
    }

    @inlinable
    package func responder(for request: inout some HTTPRequestProtocol & ~Copyable) -> (any DynamicRouteResponderProtocol)? {
        if let responder = parameterless[request.startLine] {
            return responder
        }
        let pathCount = request.pathCount()
        guard let responders = parameterized.getPositive(pathCount) else { return catchallResponder(for: &request) }
        loop: for responder in responders {
            for i in 0..<pathCount {
                let path = responder.pathComponent(at: i)
                if !path.isParameter && path.value != request.path(at: i) {
                    continue loop
                }
            }
            return responder
        }
        return catchallResponder(for: &request)
    }

    @inlinable
    func catchallResponder(for request: inout some HTTPRequestProtocol & ~Copyable) -> (any DynamicRouteResponderProtocol)? {
        var responderIndex = 0
        loop: while responderIndex < catchall.count {
            let responder = catchall[responderIndex]
            let componentsCount = responder.pathComponentsCount
            var componentIndex = 0
            while componentIndex < componentsCount {
                let component = responder.pathComponent(at: componentIndex)
                if component == .catchall {
                    return responder
                } else if !component.isParameter && component.value != request.path(at: componentIndex) {
                    responderIndex += 1
                    continue loop
                }
                componentIndex += 1
            }
            responderIndex += 1
        }
        return nil
    }
}

// MARK: Register
extension DynamicResponderStorage {
    @inlinable
    public func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    ) {
        if route.pathContainsParameters {
            var string = route.startLine()
            let buffer = DestinyRoutePathType(&string)
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