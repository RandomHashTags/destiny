
#if NonEmbedded

import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded

// MARK: DynamicRoute
/// Default Dynamic Route implementation where a complete HTTP Message, computed at compile time, is modified upon requests.
public struct DynamicRoute: DynamicRouteProtocol {
    /// Path of this route.
    public var path:[PathComponent]

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    public var contentType:String?

    /// Default HTTP Message computed by default values and static middleware.
    public var defaultResponse:DynamicResponse
    public let handler:@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    @usableFromInline package var handlerDebugDescription:String = "{ _, _ in }"

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion
    public var method:HTTPRequestMethod

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    public var status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

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
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.init(
            version: version,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            headers: headers,
            cookies: cookies,
            body: body,
            handler: handler
        )
    }

    public init(
        version: HTTPVersion = .v1_1,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                version: version,
                status: status,
                headers: headers,
                cookies: cookies,
                body: body,
                contentType: nil,
                charset: nil
            ),
            parameters: []
        )
        self.handler = handler
    }
}

#if StaticMiddleware
// MARK: Apply static middleware
extension DynamicRoute {
    #if Inlinable
    @inlinable
    #endif
    public mutating func applyStaticMiddleware(_ middleware: [some StaticMiddlewareProtocol]) throws(AnyError) {
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
        var response:String = "\(defaultResponse)"
        #if GenericDynamicResponse
        if useGenerics {
            // TODO: convert body to `IntermediateBody`
            if let b = defaultResponse.message.body as? StaticString {
                response = genericResponse(b)
            } else if let b = defaultResponse.message.body as? String {
                response = genericResponse(b)
            } else {
                response = genericResponse(Optional<StaticString>.none)
            }
        }
        #endif
        return """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(response),
            logic: \(handlerDebugDescription)
        )
        """
    }

    #if GenericDynamicResponse
    private func genericResponse<Body: ResponseBodyProtocol>(_ body: Body?) -> String {
        let response = GenericDynamicResponse(
            message: GenericHTTPResponseMessage<Body, HTTPCookie>(
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

#endif