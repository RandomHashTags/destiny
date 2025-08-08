
import DestinyBlueprint

// MARK: StaticRedirectionRoute
/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute: RedirectionRouteProtocol {
    /// The endpoint that has been moved.
    public package(set) var from:[String]

    /// The redirection endpoint.
    public package(set) var to:[String]

    public let method:any HTTPRequestMethodProtocol

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion

    /// Status of this redirection route.
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.movedPermanently.code,
        from: [StaticString],
        isCaseSensitive: Bool = true,
        to: [StaticString]
    ) {
        self.version = version
        self.method = method
        self.status = status
        self.from = from.map({ $0.description })
        self.isCaseSensitive = isCaseSensitive
        self.to = to.map({ $0.description })
    }

    @inlinable
    public func fromStartLine() -> String {
        return "\(method.rawNameString()) /\(from.joined(separator: "/")) \(version.string)"
    }

    public func response() -> HTTPResponseMessage {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        headers["Location"] = "/" + to.joined(separator: "/")
        return HTTPResponseMessage(version: version, status: status, headers: headers, cookies: [], body: nil, contentType: nil, charset: nil)
    }
}