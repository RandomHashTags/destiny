
import DestinyBlueprint

/// Default mutable storage that handles dynamic routes.
public struct DynamicResponderStorage: DynamicResponderStorageProtocol {
    /// The dynamic routes without parameters.
    public var parameterless:[DestinyRoutePathType:any DynamicRouteResponderProtocol]

    /// The dynamic routes with parameters.
    public var parameterized:[[any DynamicRouteResponderProtocol]]

    public var catchall:[any DynamicRouteResponderProtocol]

    public init(
        parameterless: [DestinyRoutePathType:any DynamicRouteResponderProtocol],
        parameterized: [[any DynamicRouteResponderProtocol]],
        catchall: [any DynamicRouteResponderProtocol]
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
        self.catchall = catchall
    }

    public var debugDescription: String {
        var parameterlessString = "[:]"
        if !parameterless.isEmpty {
            parameterlessString.removeLast(2)
            parameterlessString += "\n" + parameterless.map({ "// \($0.key.stringSIMD())\n\($0.key):\($0.value)" }).joined(separator: ",\n") + "\n]"
        }
        var parameterizedString = "[]"
        if !parameterized.isEmpty {
            parameterizedString.removeLast()
            parameterizedString += "\n" + parameterized.map({ "[" + $0.map({ "\($0)" }).joined(separator: ",\n") + "\n]" }).joined(separator: ",\n") + "\n]"
        }
        var catchallString = "[]"
        if !catchall.isEmpty {
            catchallString.removeLast()
            catchallString += "\n" + catchall.map({ "\($0)" }).joined(separator: ",\n") + "\n]"
        }
        return """
        DynamicResponderStorage(
            parameterless: \(parameterlessString),
            parameterized: \(parameterizedString),
            catchall: \(catchallString)
        )
        """
    }

    @inlinable
    public mutating func register(
        version: HTTPVersion,
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    ) throws {
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

// MARK: Respond
extension DynamicResponderStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws -> Bool {
        guard let responder = responder(for: &request) else { return false }
        try await router.respondDynamically(socket: socket, request: &request, responder: responder)
        return true
    }
}

extension DynamicResponderStorage {
    @inlinable
    func responder(for request: inout some HTTPRequestProtocol & ~Copyable) -> (any DynamicRouteResponderProtocol)? {
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