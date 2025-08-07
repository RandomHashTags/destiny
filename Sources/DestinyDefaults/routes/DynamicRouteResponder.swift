
import DestinyBlueprint

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder: DynamicRouteResponderProtocol, CustomDebugStringConvertible {
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let _defaultResponse:DynamicResponse
    public let logic:@Sendable (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) async throws(ResponderError) -> Void
    private let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: DynamicResponse,
        logic: @Sendable @escaping (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) async throws(ResponderError) -> Void,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self._defaultResponse = defaultResponse
        self.logic = logic
        self.logicDebugDescription = logicDebugDescription
    }

    public var debugDescription: String {
        """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(_defaultResponse),
            logic: \(logicDebugDescription)
        )
        """
    }

    @inlinable
    public func defaultResponse() -> DynamicResponse {
        return _defaultResponse
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
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) async throws(ResponderError) {
        // TODO: fix
        //try await logic(&anyRequest, &anyResponse)
        do throws(SocketError) {
            try await response.write(to: socket)
        } catch {
            throw .socketError(error)
        }
    }
}