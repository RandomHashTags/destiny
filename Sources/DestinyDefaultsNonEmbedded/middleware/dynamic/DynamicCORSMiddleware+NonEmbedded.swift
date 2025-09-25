
#if CORS && HTTPStandardRequestHeaders

import DestinyBlueprint
import DestinyDefaults

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
    public init(
        allowedOrigin: CORSMiddlewareAllowedOrigin = .originBased,
        allowedHeaders: Set<HTTPStandardRequestHeader> = [.accept, .authorization, .contentType, .origin],
        allowedMethods: [any HTTPRequestMethodProtocol] = [
            HTTPStandardRequestMethod.get,
            HTTPStandardRequestMethod.post,
            HTTPStandardRequestMethod.put,
            HTTPStandardRequestMethod.options,
            HTTPStandardRequestMethod.delete,
            HTTPStandardRequestMethod.patch
        ],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPStandardRequestHeader>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        self.init(
            allowedOrigin: allowedOrigin,
            allowedHeaders: allowedHeaders,
            allowedMethods: allowedMethods.map({ .init($0) }),
            allowCredentials: allowCredentials,
            exposedHeaders: exposedHeaders,
            maxAge: maxAge
        )
    }
}

#endif