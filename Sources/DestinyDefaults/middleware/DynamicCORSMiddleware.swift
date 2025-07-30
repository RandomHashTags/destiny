
import DestinyBlueprint

// MARK: DynamicCORSMiddleware
/// Default dynamic `CORSMiddlewareProtocol` implementation that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware: CORSMiddlewareProtocol, DynamicMiddlewareProtocol {
    public let allowedOrigin:CORSMiddlewareAllowedOrigin
    public let logicKind:DynamicCORSLogic

    /// Default initializer to create a `DynamicCORSMiddleware`.
    ///
    /// - Parameters:
    ///   - allowedOrigin: Supported origins that allow CORS. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-origin).
    ///   - allowedHeaders: The allowed request headers. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-headers).
    ///   - allowedMethods: Supported request methods that allow CORS. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-methods).
    ///   - allowCredentials: Whether or not cookies and other credentials are present in the response. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-allow-credentials).
    ///   - exposedHeaders: Headers that JavaScript in browsers is allowed to access. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-expose-headers).
    ///   - maxAge: How long the response to the preflight request can be cached without sending another preflight request; measured in seconds. [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#access-control-max-age).
    public init(
        allowedOrigin: CORSMiddlewareAllowedOrigin = .originBased,
        allowedHeaders: Set<HTTPRequestHeader> = [.accept, .authorization, .contentType, .origin],
        allowedMethods: [any HTTPRequestMethodProtocol] = [
            HTTPStandardRequestMethod.get,
            HTTPStandardRequestMethod.post,
            HTTPStandardRequestMethod.put,
            HTTPStandardRequestMethod.options,
            HTTPStandardRequestMethod.delete,
            HTTPStandardRequestMethod.patch
        ],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPRequestHeader>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        self.allowedOrigin = allowedOrigin
        let allowedHeaders = allowedHeaders.map({ $0.rawNameString }).joined(separator: ",")
        let allowedMethods = allowedMethods.map({ "\($0)" }).joined(separator: ",")
        let exposedHeaders = exposedHeaders?.map({ $0.rawNameString }).joined(separator: ",")
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
    }

    @inlinable
    static func maxAgeString(_ input: Int?) -> String? {
        guard let input else { return nil }
        return "\(input)"
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        guard request.header(forKey: "Origin") != nil else { return true }
        allowedOrigin.apply(request: &request, response: &response)
        try await logicKind.apply(to: &response)
        return true
    }
}

// MARK: Logic variants
extension DynamicCORSMiddleware {
    @inlinable
    static func handleSharedLogic(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        response.setHeader(key: "Access-Control-Allow-Headers", value: allowedHeaders)
        response.setHeader(key: "Access-Control-Allow-Methods", value: allowedMethods)
    }
}

extension DynamicCORSMiddleware {
    @inlinable
    static func logic_allowCredentials_exposedHeaders_maxAge(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAgeString)
        response.setHeader(key: "Access-Control-Allow-Credentials", value: "true")
    }

    @inlinable
    static func logic_allowCredentials_exposedHeaders(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        response.setHeader(key: "Access-Control-Allow-Credentials", value: "true")
    }

    @inlinable
    static func logic_allowCredentials_maxAge(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        logic_allowCredentials(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "Access-Control-Max-Age", value: maxAgeString)
    }

    @inlinable
    static func logic_allowCredentials(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "Access-Control-Allow-Credentials", value: "true")
    }
}

extension DynamicCORSMiddleware {
    @inlinable
    static func logic_exposedHeaders_maxAge(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String,
        _ maxAgeString: String
    ) {
        logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        response.setHeader(key: "Access-Control-Max-Age", value: maxAgeString)
    }

    @inlinable
    static func logic_exposedHeaders(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ exposedHeaders: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "Access-Control-Expose-Headers", value: exposedHeaders)
    }
}

extension DynamicCORSMiddleware {
    @inlinable
    static func logic_maxAge(
        _ response: inout any DynamicResponseProtocol,
        _ allowedHeaders: String,
        _ allowedMethods: String,
        _ maxAgeString: String
    ) {
        Self.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        response.setHeader(key: "Access-Control-Max-Age", value: maxAgeString)
    }
}