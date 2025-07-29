
import DestinyBlueprint

// MARK: DynamicCORSMiddleware
/// Default dynamic `CORSMiddlewareProtocol` implementation that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware: CORSMiddlewareProtocol, DynamicMiddlewareProtocol {
    public let logic:@Sendable (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) async throws -> Void

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
            HTTPRequestMethod.get,
            HTTPRequestMethod.post,
            HTTPRequestMethod.put,
            HTTPRequestMethod.options,
            HTTPRequestMethod.delete,
            HTTPRequestMethod.patch
        ],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPRequestHeader>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        let originLogic:(inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) -> Void
        switch allowedOrigin {
        case .all:
            originLogic = {
                $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: "*")
            }
        case .any(let origins):
            originLogic = {
                if let origin = $0.header(forKey: HTTPRequestHeader.originRawName), origins.contains(origin) {
                    $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: origin)
                }
            }
        case .custom(let s):
            originLogic = {
                $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: "\(s)")
            }
        case .none:
            originLogic = { _, _ in }
        case .originBased:
            originLogic = {
                $1.setHeader(key: HTTPResponseHeader.varyRawName, value: "origin")
                if let origin = $0.header(forKey: HTTPRequestHeader.originRawName) {
                    $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: origin)
                }
            }
        }

        let allowedHeaders = allowedHeaders.map({ $0.rawNameString }).joined(separator: ",")
        let allowedMethods = allowedMethods.map({ "\($0)" }).joined(separator: ",")
        let exposedHeaders = exposedHeaders?.map({ $0.rawNameString }).joined(separator: ",")
        if allowCredentials {
            if let exposedHeaders {
                if let maxAge {
                    logic = {
                        Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                        $1.setHeader(key: HTTPResponseHeader.accessControlAllowCredentialsRawName, value: "true")
                        $1.setHeader(key: HTTPResponseHeader.accessControlExposeHeadersRawName, value: exposedHeaders)
                        $1.setHeader(key: HTTPResponseHeader.accessControlMaxAgeRawName, value: "\(maxAge)")
                    }
                } else {
                    logic = {
                        Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                        $1.setHeader(key: HTTPResponseHeader.accessControlAllowCredentialsRawName, value: "true")
                        $1.setHeader(key: HTTPResponseHeader.accessControlExposeHeadersRawName, value: exposedHeaders)
                    }
                }
            } else if let maxAge {
                logic = {
                    Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                    $1.setHeader(key: HTTPResponseHeader.accessControlAllowCredentialsRawName, value: "true")
                    $1.setHeader(key: HTTPResponseHeader.accessControlMaxAgeRawName, value: "\(maxAge)")
                }
            } else {
                logic = {
                    Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                    $1.setHeader(key: HTTPResponseHeader.accessControlAllowCredentialsRawName, value: "true")
                }
            }
        } else if let exposedHeaders {
            if let maxAge {
                logic = {
                    Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                    $1.setHeader(key: HTTPResponseHeader.accessControlExposeHeadersRawName, value: exposedHeaders)
                    $1.setHeader(key: HTTPResponseHeader.accessControlMaxAgeRawName, value: "\(maxAge)")
                }
            } else {
                logic = {
                    Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                    $1.setHeader(key: HTTPResponseHeader.accessControlExposeHeadersRawName, value: exposedHeaders)
                }
            }
        } else if let maxAge {
            logic = {
                Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
                $1.setHeader(key: HTTPResponseHeader.accessControlMaxAgeRawName, value: "\(maxAge)")
            }
        } else {
            logic = {
                Self.handleSharedLogic(&$0, &$1, originLogic, allowedHeaders, allowedMethods)
            }
        }
    }
    public init(_ logic: @escaping @Sendable (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) -> Void) {
        self.logic = logic
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        guard request.header(forKey: HTTPRequestHeader.originRawName) != nil else { return true }
        try await logic(&request, &response)
        return true
    }
}

extension DynamicCORSMiddleware {
    @inlinable
    static func handleSharedLogic(
        _ request: inout any HTTPRequestProtocol,
        _ response: inout any DynamicResponseProtocol,
        _ originLogic: (inout any HTTPRequestProtocol, inout any DynamicResponseProtocol) -> Void,
        _ allowedHeaders: String,
        _ allowedMethods: String
    ) {
        originLogic(&request, &response)
        response.setHeader(key: HTTPResponseHeader.accessControlAllowHeadersRawName, value: allowedHeaders)
        response.setHeader(key: HTTPResponseHeader.accessControlAllowMethodsRawName, value: allowedMethods)
    }
}

// MARK: Allowed origin logic
// TODO: determined whether or not this improves performance instead of using the heap allocated `originLogic`
extension DynamicCORSMiddleware {
    @inlinable
    func allowedOrigin_all(_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) {
    }
}