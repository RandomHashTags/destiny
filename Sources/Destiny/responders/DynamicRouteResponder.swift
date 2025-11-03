
#if NonEmbedded

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder: Sendable {
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let _defaultResponse:DynamicResponse
    public let logic:@Sendable (inout HTTPRequest, inout any DynamicResponseProtocol) async throws -> Void
    package let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: DynamicResponse,
        logic: (@Sendable (inout HTTPRequest, inout any DynamicResponseProtocol) async throws -> Void)?,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self._defaultResponse = defaultResponse
        self.logic = logic ?? { _, _ in }
        self.logicDebugDescription = logicDebugDescription
    }

    public func defaultResponse() -> DynamicResponse {
        return _defaultResponse
    }

    public var pathComponentsCount: Int {
        path.count
    }

    public func pathComponent(at index: Int) -> PathComponent {
        path[index]
    }

    public func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
        for index in parameterPathIndexes {
            yield(index)
        }
    }
}

// MARK: Respond
extension DynamicRouteResponder {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest,
        response: inout some DynamicResponseProtocol
    ) throws(DestinyError) {
        var anyRequest = request.copy()
        var anyResponse:any DynamicResponseProtocol = response
        Task {
            do {
                try await logic(&anyRequest, &anyResponse)
            } catch {
                let err = DestinyError.custom("dynamicRouteResponderError;while executing dynamic logic: \(error)")
                if !router.respondWithError(provider: provider, request: &anyRequest, error: err) {
                    anyRequest.fileDescriptor.flush(provider: provider)
                }
                return
            }
            do throws(DestinyError) {
                try anyResponse.write(to: anyRequest.fileDescriptor)
                anyRequest.fileDescriptor.flush(provider: provider)
            } catch {
                if !router.respondWithError(provider: provider, request: &anyRequest, error: error) {
                    anyRequest.fileDescriptor.flush(provider: provider)
                }
                return
            }
        }
    }
}

// MARK: Conformances
extension DynamicRouteResponder: DynamicRouteResponderProtocol {}

#endif