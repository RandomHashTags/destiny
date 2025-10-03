
#if StaticRedirectionRoute

import DestinyEmbedded

/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute: Sendable {
    /// Endpoint that has been moved.
    public package(set) var from:[String]

    /// Endpoint to redirect to.
    public package(set) var to:[String]

    public let method:HTTPRequestMethod

    /// Status of this redirection route.
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion

    #if Inlinable
    @inlinable
    #endif
    public func fromStartLine() -> String {
        return "\(method.rawNameString()) /\(from.joined(separator: "/")) \(version.string)"
    }
}

// MARK: Init
extension StaticRedirectionRoute {
    public init(
        version: HTTPVersion = .v1_1,
        method: HTTPRequestMethod,
        status: HTTPResponseStatus.Code = 301, // moved permanently
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
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

extension StaticRedirectionRoute {
    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        status: HTTPResponseStatus.Code = 301, // moved permanently
        from: [StaticString],
        isCaseSensitive: Bool = true,
        to: [StaticString]
    ) {
        self.init(
            version: version,
            method: .init(method),
            status: status,
            from: from,
            isCaseSensitive: isCaseSensitive,
            to: to
        )
    }
}

// MARK: Conformances
extension StaticRedirectionRoute: RedirectionRouteProtocol {}

#endif

#endif