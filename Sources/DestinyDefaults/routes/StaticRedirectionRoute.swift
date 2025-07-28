
import DestinyBlueprint

// MARK: StaticRedirectionRoute
/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute: RedirectionRouteProtocol {
    public package(set) var from:[String]
    public package(set) var to:[String]
    public let version:HTTPVersion
    public let method:any HTTPRequestMethodProtocol
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.movedPermanently.code,
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

    public func response() throws -> String {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        headers["Location"] = "/" + to.joined(separator: "/")
        return HTTPResponseMessage.create(escapeLineBreak: true, version: version, status: status, headers: headers, body: nil, contentType: nil, charset: nil)
    }
}