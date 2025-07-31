
public enum CORSMiddlewareAllowedOrigin: Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased

    @inlinable
    public func apply(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) {
        switch self {
        case .all:
            Self.applyAll(response: &response)
        case .any(let origins):
            Self.applyAny(request: &request, response: &response, origins: origins)
        case .custom(let s):
            Self.applyCustom(response: &response, string: s)
        case .none:
            break
        case .originBased:
            Self.applyOriginBased(request: &request, response: &response)
        }
    }
}

extension CORSMiddlewareAllowedOrigin {
    @inlinable
    static func applyAll(
        response: inout some DynamicResponseProtocol
    ) {
        response.setHeader(key: "Access-Control-Allow-Origin", value: "*")
    }

    @inlinable
    static func applyAny(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol,
        origins: Set<String>
    ) {
        if let origin = request.header(forKey: "Origin"), origins.contains(origin) {
            response.setHeader(key: "Access-Control-Allow-Origin", value: origin)
        }
    }

    @inlinable
    static func applyCustom(
        response: inout some DynamicResponseProtocol,
        string: String
    ) {
        response.setHeader(key: "Access-Control-Allow-Origin", value: string)
    }

    @inlinable
    static func applyOriginBased(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) {
        response.setHeader(key: "Vary", value: "origin")
        if let origin = request.header(forKey: "Origin") {
            response.setHeader(key: "Access-Control-Allow-Origin", value: origin)
        }
    }
}