
import DestinyBlueprint
import DestinyDefaults
import Logging

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder: DynamicRouteResponderProtocol { // TODO: avoid existentials / support embedded
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let _defaultResponse:DynamicResponse
    public let logic:@Sendable (inout any HTTPRequestProtocol & ~Copyable, inout any DynamicResponseProtocol) async throws -> Void
    package let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: DynamicResponse,
        logic: @Sendable @escaping (inout any HTTPRequestProtocol & ~Copyable, inout any DynamicResponseProtocol) async throws -> Void,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self._defaultResponse = defaultResponse
        self.logic = logic
        self.logicDebugDescription = logicDebugDescription
    }

    #if Inlinable
    @inlinable
    #endif
    public func defaultResponse() -> DynamicResponse {
        return _defaultResponse
    }

    #if Inlinable
    @inlinable
    #endif
    public var pathComponentsCount: Int {
        path.count
    }

    #if Inlinable
    @inlinable
    #endif
    public func pathComponent(at index: Int) -> PathComponent {
        path[index]
    }

    #if Inlinable
    @inlinable
    #endif
    public func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
        for index in parameterPathIndexes {
            yield(index)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var anyRequest:any HTTPRequestProtocol & ~Copyable = request.copy()
        var anyResponse:any DynamicResponseProtocol = response
        Task {
            var err:ResponderError? = nil
            do {
                try await logic(&anyRequest, &anyResponse)
            } catch {
                err = ResponderError(identifier: "dynamicRouteResponderError", reason: "while executing dynamic logic: \(error)")
            }
            if let err {
                if !router.respondWithError(socket: socket, error: err, request: &anyRequest, completionHandler: completionHandler) {
                    completionHandler()
                }
                return
            }
            do throws(SocketError) {
                try anyResponse.write(to: socket)
            } catch {
                err = .socketError(error)
            }
            if let err {
                if !router.respondWithError(socket: socket, error: err, request: &anyRequest, completionHandler: completionHandler) {
                    completionHandler()
                }
                return
            }
            completionHandler()
        }
    }
}