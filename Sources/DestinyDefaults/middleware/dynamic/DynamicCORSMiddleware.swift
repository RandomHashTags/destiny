
#if CORS

import DestinyBlueprint

// MARK: DynamicCORSMiddleware
/// Default dynamic `CORSMiddlewareProtocol` implementation that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware: CORSMiddlewareProtocol {
    public let allowedOrigin:CORSMiddlewareAllowedOrigin
    public let logicKind:DynamicCORSLogic

    public init(allowedOrigin: CORSMiddlewareAllowedOrigin, logicKind: DynamicCORSLogic) {
        self.allowedOrigin = allowedOrigin
        self.logicKind = logicKind
    }

    #if Inlinable
    @inlinable
    #endif
    package static func maxAgeString(_ input: Int?) -> String? {
        guard let input else { return nil }
        return "\(input)"
    }
}

// MARK: Handle
extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        do throws(SocketError) {
            guard try request.header(forKey: "origin") != nil else { return true }
            try allowedOrigin.apply(request: &request, response: &response)
            logicKind.apply(to: &response)
            return true
        } catch {
            throw .socketError(error)
        }
    }
}

// MARK: Init
extension DynamicCORSMiddleware {
    /// Default initializer to create a `DynamicCORSMiddleware`.
    ///
    /// - Parameters:
    ///   - allowedOrigin: Supported origins that allow CORS. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-origin).
    ///   - allowedHeaders: Allowed request headers. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-headers).
    ///   - allowedMethods: Supported request methods that allow CORS. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-methods).
    ///   - allowCredentials: Whether or not cookies and other credentials are present in the response. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-credentials).
    ///   - exposedHeaders: Headers that JavaScript in browsers is allowed to access. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-expose-headers).
    ///   - maxAge: How long the response to the preflight request can be cached without sending another preflight request; measured in seconds. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-max-age).
    public static func build(
        allowedOrigin: CORSMiddlewareAllowedOrigin = .originBased,
        allowedHeaders: Set<String> = ["accept", "authorization", "content-type", "origin"],
        allowedMethods: [String] = [
            "GET",
            "POST",
            "PUT",
            "OPTIONS",
            "DELETE",
            "PATCH"
        ],
        allowCredentials: Bool = false,
        exposedHeaders: Set<String>? = nil,
        maxAge: Int? = 3600 // one hour
    ) -> Self {
        let logicKind:DynamicCORSLogic
        let allowedHeaders = allowedHeaders.joined(separator: ",")
        let allowedMethods = allowedMethods.joined(separator: ",")
        let exposedHeaders = exposedHeaders?.joined(separator: ",")
        if allowCredentials {
            if let exposedHeaders {
                if let maxAgeString = Self.maxAgeString(maxAge) {
                    logicKind = .allowCredentials_exposedHeaders_maxAge(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, exposedHeaders: exposedHeaders, maxAge: maxAgeString)
                } else {
                    logicKind = .allowCredentials_exposedHeaders(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, exposedHeaders: exposedHeaders)
                }
            } else if let maxAgeString = Self.maxAgeString(maxAge) {
                logicKind = .allowCredentials_maxAge(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, maxAge: maxAgeString)
            } else {
                logicKind = .allowCredentials(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods)
            }
        } else if let exposedHeaders {
            if let maxAgeString = Self.maxAgeString(maxAge) {
                logicKind = .exposedHeaders_maxAge(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, exposedHeaders: exposedHeaders, maxAge: maxAgeString)
            } else {
                logicKind = .exposedHeaders(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, exposedHeaders: exposedHeaders)
            }
        } else if let maxAgeString = Self.maxAgeString(maxAge) {
            logicKind = .maxAge(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, maxAge: maxAgeString)
        } else {
            logicKind = .minimum(allowedHeaders: allowedHeaders, allowedMethods: allowedMethods)
        }
        return self.init(allowedOrigin: allowedOrigin, logicKind: logicKind)
    }

    public init() {
        self = Self.build()
    }

    #if HTTPStandardRequestHeaders && HTTPStandardRequestMethods
    public init(
        allowedOrigin: CORSMiddlewareAllowedOrigin = .originBased,
        allowedHeaders: Set<HTTPStandardRequestHeader> = [.accept, .authorization, .contentType, .origin],
        allowedMethods: [HTTPRequestMethod] = [
            .init(HTTPStandardRequestMethod.get),
            .init(HTTPStandardRequestMethod.post),
            .init(HTTPStandardRequestMethod.put),
            .init(HTTPStandardRequestMethod.options),
            .init(HTTPStandardRequestMethod.delete),
            .init(HTTPStandardRequestMethod.patch)
        ],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPStandardRequestHeader>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        let allowedHeaders = Set(allowedHeaders.map({ $0.canonicalName }))
        let allowedMethods = allowedMethods.map({ $0.rawNameString() })
        let exposedLiteralHeaders:Set<String>?
        if let e = exposedHeaders {
            exposedLiteralHeaders = Set(e.map({ $0.canonicalName }))
        } else {
            exposedLiteralHeaders = nil
        }
        self = Self.build(
            allowedOrigin: allowedOrigin,
            allowedHeaders: allowedHeaders,
            allowedMethods: allowedMethods,
            allowCredentials: allowCredentials,
            exposedHeaders: exposedLiteralHeaders,
            maxAge: maxAge
        )
    }
    #endif
}


// MARK: Logic variants
extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func handleSharedLogic(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        response.setHeader(key: "access-control-allow-headers", value: allowedHeaders)
        response.setHeader(key: "access-control-allow-methods", value: allowedMethods)
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_exposedHeaders_maxAge(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAgeString)
        response.setHeader(key: "access-control-allow-credentials", value: "true")
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_exposedHeaders(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        response.setHeader(key: "access-control-allow-credentials", value: "true")
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_maxAge(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        logic_allowCredentials(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "access-control-max-age", value: maxAgeString)
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "access-control-allow-credentials", value: "true")
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_exposedHeaders_maxAge(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        response.setHeader(key: "access-control-max-age", value: maxAgeString)
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_exposedHeaders(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "access-control-expose-headers", value: exposedHeaders)
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_maxAge(
        _ response: inout some DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "access-control-max-age", value: maxAgeString)
    }
}

// MARK: HTTPHeadersProtocol
extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func handleSharedLogic(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        headers["access-control-allow-headers"] = allowedHeaders
        headers["access-control-allow-methods"] = allowedMethods
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_exposedHeaders_maxAge(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders_maxAge(&headers, allowedHeaders, allowedMethods, exposedHeaders, maxAgeString)
        headers["access-control-allow-credentials"] = "true"
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_exposedHeaders(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        logic_exposedHeaders(&headers, allowedHeaders, allowedMethods, exposedHeaders)
        headers["access-control-allow-credentials"] = "true"
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials_maxAge(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        logic_allowCredentials(&headers, allowedHeaders, allowedMethods)
        headers["access-control-max-age"] = maxAgeString
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_allowCredentials(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        Self.handleSharedLogic(&headers, allowedHeaders, allowedMethods)
        headers["access-control-allow-credentials"] = "true"
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_exposedHeaders_maxAge(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders(&headers, allowedHeaders, allowedMethods, exposedHeaders)
        headers["access-control-max-age"] = maxAgeString
    }

    #if Inlinable
    @inlinable
    #endif
    static func logic_exposedHeaders(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        Self.handleSharedLogic(&headers, allowedHeaders, allowedMethods)
        headers["access-control-expose-headers"] = exposedHeaders
    }
}

extension DynamicCORSMiddleware {
    #if Inlinable
    @inlinable
    #endif
    static func logic_maxAge(
        _ headers: inout some HTTPHeadersProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        Self.handleSharedLogic(&headers, allowedHeaders, allowedMethods)
        headers["access-control-max-age"] = maxAgeString
    }
}

// MARK: Conformances
extension DynamicCORSMiddleware: OpaqueDynamicMiddlewareProtocol {}

#endif