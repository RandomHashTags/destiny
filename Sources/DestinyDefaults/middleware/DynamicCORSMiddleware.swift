//
//  DynamicCORSMiddleware.swift
//
//
//  Created by Evan Anderson on 12/8/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax

/// The default dynamic `CORSMiddlewareProtocol` that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware : CORSMiddlewareProtocol, DynamicMiddlewareProtocol {
    private let modifications:[@Sendable (inout RequestProtocol, inout DynamicResponseProtocol) -> Void]

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
        allowedHeaders: Set<HTTPField.Name> = [.accept, .authorization, .contentType, .origin],
        allowedMethods: Set<HTTPRequest.Method> = [.get, .post, .put, .options, .delete, .patch],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPField.Name>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        var modifications:[@Sendable (inout RequestProtocol, inout DynamicResponseProtocol) -> Void] = []
        modifications.reserveCapacity(5)
        switch allowedOrigin {
            case .all:
                modifications.append { $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = "*" }
            case .any(let origins):
                modifications.append {
                    guard let origin:String = $0.headers[HTTPField.Name.origin.rawName], origins.contains(origin) else { return }
                    $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = origin
                }
            case .custom(let s):
                modifications.append { $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = s }
            case .none:
                break
            case .originBased:
                modifications.append {
                    $1.headers[HTTPField.Name.vary.rawName] = "origin"
                    guard let origin:String = $0.headers[HTTPField.Name.origin.rawName] else { return }
                    $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = origin
                }
        }

        let allowedHeaders:String = allowedHeaders.map({ $0.rawName  }).joined(separator: ",")
        let allowedMethods:String = allowedMethods.map({ $0.rawValue }).joined(separator: ",")
        modifications.append {
            $1.headers[HTTPField.Name.accessControlAllowHeaders.rawName] = allowedHeaders
            $1.headers[HTTPField.Name.accessControlAllowMethods.rawName] = allowedMethods
        }
        if allowCredentials {
            modifications.append { $1.headers[HTTPField.Name.accessControlAllowCredentials.rawName] = "true" }
        }
        if let exposedHeaders:String = exposedHeaders?.map({ $0.rawName }).joined(separator: ",") {
            modifications.append { $1.headers[HTTPField.Name.accessControlExposeHeaders.rawName] = exposedHeaders }
        }
        if let maxAge:Int = maxAge {
            let s:String = String(maxAge)
            modifications.append { $1.headers[HTTPField.Name.accessControlMaxAge.rawName] = s }
        }
        self.modifications = modifications
    }

    public var isAsync : Bool { false }

    public func shouldHandle(request: inout RequestProtocol, response: borrowing DynamicResponseProtocol) -> Bool {
        return request.headers[HTTPField.Name.origin.rawName] != nil
    }

    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) throws {
        for modification in modifications {
            modification(&request, &response)
        }
    }

    public func handleAsync(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws {}

    public func onError(request: inout RequestProtocol, response: inout DynamicResponseProtocol, error: Error) {}

    public func onErrorAsync(request: inout RequestProtocol, response: inout DynamicResponseProtocol, error: Error) async {}

    

    public var debugDescription: String { "DynamicCORSMiddleware()" }

}

public extension DynamicCORSMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> Self { // TODO: finish
        var allowedOrigin:CORSMiddlewareAllowedOrigin = .originBased
        var allowedHeaders:Set<HTTPField.Name> = [.accept, .authorization, .contentType, .origin]
        var allowedMethods:Set<HTTPRequest.Method> = [.get, .post, .put, .options, .delete, .patch]
        var allowCredentials:Bool = false
        var maxAge:Int? = 600
        var exposedHeaders:Set<HTTPField.Name>? = nil
        for argument in function.arguments {
            //print("DynamicCORSMiddleware;parse;argument=" + argument.debugDescription)
            switch argument.label!.text {
                case "allowedOrigin":
                    break
                case "allowedHeaders":
                    break
                case "allowedMethods":
                    allowedMethods = Set(argument.array!.elements.compactMap({ HTTPRequest.Method.parse($0.memberAccess!.declName.baseName.text) }))
                    break
                case "allowCredentials":
                    allowCredentials = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
                case "maxAge":
                    if let s:String = argument.expression.as(IntegerLiteralExprSyntax.self)?.literal.text {
                        maxAge = Int(s)
                    }
                case "exposedHeaders":
                    break
                default:
                    break
            }
        }
        return Self(allowedOrigin: allowedOrigin, allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, allowCredentials: allowCredentials, exposedHeaders: exposedHeaders, maxAge: maxAge)
    }
}