
#if CORS

public enum CORSMiddlewareAllowedOrigin: Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased
}

extension CORSMiddlewareAllowedOrigin {
    #if Inlinable
    @inlinable
    #endif
    public func apply(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(SocketError) {
        switch self {
        case .all:
            Self.applyAll(response: &response)
        case .any(let origins):
            try Self.applyAny(request: &request, response: &response, origins: origins)
        case .custom(let s):
            Self.applyCustom(response: &response, string: s)
        case .none:
            break
        case .originBased:
            try Self.applyOriginBased(request: &request, response: &response)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyAll(
        response: inout some DynamicResponseProtocol
    ) {
        response.setHeader(key: "access-control-allow-origin", value: "*")
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyAny(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol,
        origins: Set<String>
    ) throws(SocketError) {
        if let origin = try request.header(forKey: "origin"), origins.contains(origin) {
            response.setHeader(key: "access-control-allow-origin", value: origin)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyCustom(
        response: inout some DynamicResponseProtocol,
        string: String
    ) {
        response.setHeader(key: "access-control-allow-origin", value: string)
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyOriginBased(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(SocketError) {
        response.setHeader(key: "vary", value: "origin")
        if let origin = try request.header(forKey: "origin") {
            response.setHeader(key: "access-control-allow-origin", value: origin)
        }
    }
}

extension CORSMiddlewareAllowedOrigin {
    #if Inlinable
    @inlinable
    #endif
    public func apply(
        request: inout some HTTPRequestProtocol & ~Copyable,
        headers: inout some HTTPHeadersProtocol
    ) throws(SocketError) {
        switch self {
        case .all:
            Self.applyAll(headers: &headers)
        case .any(let origins):
            try Self.applyAny(request: &request, headers: &headers, origins: origins)
        case .custom(let s):
            Self.applyCustom(headers: &headers, string: s)
        case .none:
            break
        case .originBased:
            try Self.applyOriginBased(request: &request, headers: &headers)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyAll(
        headers: inout some HTTPHeadersProtocol
    ) {
        headers["access-control-allow-origin"] = "*"
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyAny(
        request: inout some HTTPRequestProtocol & ~Copyable,
        headers: inout some HTTPHeadersProtocol,
        origins: Set<String>
    ) throws(SocketError) {
        if let origin = try request.header(forKey: "origin"), origins.contains(origin) {
            headers["access-control-allow-origin"] = origin
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyCustom(
        headers: inout some HTTPHeadersProtocol,
        string: String
    ) {
        headers["access-control-allow-origin"] = string
    }

    #if Inlinable
    @inlinable
    #endif
    static func applyOriginBased(
        request: inout some HTTPRequestProtocol & ~Copyable,
        headers: inout some HTTPHeadersProtocol
    ) throws(SocketError) {
        headers["vary"] = "origin"
        if let origin = try request.header(forKey: "origin") {
            headers["access-control-allow-origin"] = origin
        }
    }
}

#endif