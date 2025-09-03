
import DestinyBlueprint

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

    #if Inlinable
    @inlinable
    #endif
    public func fromStartLine() -> String {
        return "\(method.rawNameString()) /\(from.joined(separator: "/")) \(version.string)"
    }

    public func response() -> HTTPResponseMessage {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
}