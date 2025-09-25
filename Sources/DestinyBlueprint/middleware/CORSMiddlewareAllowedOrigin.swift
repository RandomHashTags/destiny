
#if CORS

public enum CORSMiddlewareAllowedOrigin: Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased
}

    #if RequestHeaders

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
            response.setHeader(key: "Access-Control-Allow-Origin", value: "*")
        }

        #if Inlinable
        @inlinable
        #endif
        static func applyAny(
            request: inout some HTTPRequestProtocol & ~Copyable,
            response: inout some DynamicResponseProtocol,
            origins: Set<String>
        ) throws(SocketError) {
            if let origin = try request.header(forKey: "Origin"), origins.contains(origin) {
                response.setHeader(key: "Access-Control-Allow-Origin", value: origin)
            }
        }

        #if Inlinable
        @inlinable
        #endif
        static func applyCustom(
            response: inout some DynamicResponseProtocol,
            string: String
        ) {
            response.setHeader(key: "Access-Control-Allow-Origin", value: string)
        }

        #if Inlinable
        @inlinable
        #endif
        static func applyOriginBased(
            request: inout some HTTPRequestProtocol & ~Copyable,
            response: inout some DynamicResponseProtocol
        ) throws(SocketError) {
            response.setHeader(key: "Vary", value: "origin")
            if let origin = try request.header(forKey: "Origin") {
                response.setHeader(key: "Access-Control-Allow-Origin", value: origin)
            }
        }
    }

    #endif

#endif