
import DestinyBlueprint

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder: DynamicRouteResponderProtocol {
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let defaultResponse:any DynamicResponseProtocol
    public let logic:@Sendable (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) async throws -> Void
    private let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: any DynamicResponseProtocol,
        logic: @escaping @Sendable (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) async throws -> Void,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self.defaultResponse = defaultResponse
        self.logic = logic
        self.logicDebugDescription = logicDebugDescription
    }

    public var debugDescription: String {
        """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(defaultResponse),
            logic: \(logicDebugDescription)
        )
        """
    }

    @inlinable
    public func forEachPathComponent(_ yield: (PathComponent) -> Void) {
        for component in path {
            yield(component)
        }
    }

    @inlinable
    public var pathComponentsCount: Int {
        path.count
    }

    @inlinable
    public func pathComponent(at index: Int) -> PathComponent {
        path[index]
    }

    @inlinable
    public func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
        for index in parameterPathIndexes {
            yield(index)
        }
    }

    @inlinable
    public func respond(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws {
        try await logic(&request, &response)
        try await response.write(to: socket)
    }
}