
import DestinyBlueprint
import DestinyDefaults
import DestinyEmbedded

// MARK: DynamicRoute
/// Default Dynamic Route implementation where a complete HTTP Message, computed at compile time, is modified upon requests.
public struct DynamicRoute: DynamicRouteProtocol {
    /// Path of this route.
    public var path:[PathComponent]

    public var method:HTTPRequestMethod

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    public var contentType:String?

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    public var status:HTTPResponseStatus.Code

    /// Default HTTP Message computed by default values and static middleware.
    public var defaultResponse:DynamicResponse
    var handlerDebugDescription = "{ _, _ in }"

    public let isCaseSensitive:Bool

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion

    public var pathCount: Int {
        path.count
    }

    public var pathContainsParameters: Bool {
        path.firstIndex(where: { $0.isParameter }) == nil
    }

    public func startLine() -> String {
        return "\(method.rawNameString()) /\(path.map({ $0.slug }).joined(separator: "/")) \(version.string)" 
    }

    public mutating func insertPath(contentsOf newElements: some Collection<PathComponent>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

// MARK: Init
extension DynamicRoute {
    public init(
        head: HTTPResponseMessageHead = .default,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.init(
            head: head,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            contentType: contentType,
            body: body
        )
    }
    public init(
        head: HTTPResponseMessageHead = .default,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.version = head.version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = head.status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                head: head,
                body: body,
                contentType: nil,
                charset: nil
            ),
            parameters: []
        )
    }
}

#if StaticMiddleware
// MARK: Apply static middleware
extension DynamicRoute {
    public mutating func applyStaticMiddleware(_ middleware: [StaticMiddleware]) throws(AnyError) {
        let path = path.map({ $0.slug }).joined(separator: "/")
        for middleware in middleware {
            if middleware.handles(
                version: defaultResponse.message.version,
                path: path,
                method: method,
                contentType: contentType,
                status: status
            ) {
                try middleware.apply(contentType: &contentType, to: &defaultResponse)
            }
        }
    }
}
#endif

// MARK: Responder DebugDescription
extension DynamicRoute {
    /// String representation of an initialized route responder conforming to `DynamicRouteResponderProtocol`.
    public func responderDebugDescription(useGenerics: Bool) -> String {
        let response:String
        #if hasFeature(Embedded) || EMBEDDED
        if useGenerics {
            // TODO: convert body to `IntermediateBody`
            if let b = defaultResponse.message.body as? StaticString {
                response = genericResponse(b)
            } else if let b = defaultResponse.message.body as? String {
                response = genericResponse(b)
            } else {
                response = genericResponse(Optional<String>.none)
            }
        }
        #else
        response = "\(defaultResponse)"
        #endif

        return """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(response),
            logic: \(handlerDebugDescription)
        )
        """
    }

    #if hasFeature(Embedded) || EMBEDDED
    private func genericResponse<Body: ResponseBodyProtocol>(_ body: Body?) -> String { // TODO: fix
        let response = DynamicResponse(
            message: HTTPResponseMessage<Body>(
                head: defaultResponse.message.head,
                body: body,
                contentType: defaultResponse.message.contentType,
                charset: defaultResponse.message.charset
            ),
            parameters: defaultResponse.parameters
        )
        return "\(response)"
    }
    #endif
}