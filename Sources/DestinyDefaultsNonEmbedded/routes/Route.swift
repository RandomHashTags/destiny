
import DestinyBlueprint

/// Convenient route storage used by the macros to optimally manage routes and their responses.
public struct Route: Sendable {
    public var path:[PathComponent]
    public let contentType:String?

    public var defaultResponse:DynamicResponse
    public let handler:(@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)?
    @usableFromInline package var handlerDebugDescription:String? = nil

    public let isCaseSensitive:Bool
    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
    public let charset:Charset?
    public let version:HTTPVersion
}

// MARK: Init
extension Route {
    public init(
        head: HTTPResponseMessageHead,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.version = head.version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = head.status
        self.contentType = contentType
        self.charset = charset
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                head: head,
                body: body,
                contentType: contentType,
                charset: charset
            ),
            parameters: []
        )
        self.handler = handler
    }
}

// MARK: Conformances
extension Route: RouteProtocol {}