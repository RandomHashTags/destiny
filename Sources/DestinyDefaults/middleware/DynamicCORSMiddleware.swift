//
//  DynamicCORSMiddleware.swift
//
//
//  Created by Evan Anderson on 12/8/24.
//

import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicCORSMiddleware
/// Default dynamic `CORSMiddlewareProtocol` implementation that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware: CORSMiddlewareProtocol, DynamicMiddlewareProtocol {
    public let logic:@Sendable (inout any RequestProtocol, inout any DynamicResponseProtocol) async throws -> Void
    private let logicDebugDescription:String

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
        allowedMethods: Set<HTTPRequestMethod> = [.get, .post, .put, .options, .delete, .patch],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPRequestHeader>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        var logicDD = "{\n"
        switch allowedOrigin {
        case .all:
            logicDD += "$1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: \"*\")"
        case .any(let origins):
            logicDD += "if let origin:String = $0.header(forKey: HTTPRequestHeader.originRawName), (\(origins) as Set<String>).contains(origin) { $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: origin) }"
        case .custom(let s):
            logicDD += "$1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: \"" + s + "\")"
        case .none:
            break
        case .originBased:
            logicDD += "$1.setHeader(key: HTTPResponseHeader.varyRawName, value: \"origin\")"
            logicDD += "\nif let origin:String = $0.header(forKey: HTTPRequestHeader.originRawName) { $1.setHeader(key: HTTPResponseHeader.accessControlAllowOriginRawName, value: origin) }"
        }

        let allowedHeaders = allowedHeaders.map({ $0.rawNameString }).joined(separator: ",")
        let allowedMethods = allowedMethods.map({ $0.rawNameString }).joined(separator: ",")
        logicDD += "\n$1.setHeader(key: HTTPResponseHeader.accessControlAllowHeadersRawName, value: \"" + allowedHeaders + "\")"
        logicDD += "\n$1.setHeader(key: HTTPResponseHeader.accessControlAllowMethodsRawName, value: \"" + allowedMethods + "\")"
        if allowCredentials {
            logicDD += "\n$1.setHeader(key: HTTPResponseHeader.accessControlAllowCredentialsRawName, value: \"true\")"
        }
        if let exposedHeaders = exposedHeaders?.map({ $0.rawNameString }).joined(separator: ",") {
            logicDD += "\n$1.setHeader(key: HTTPResponseHeader.accessControlExposeHeadersRawName, value: \"" + exposedHeaders + "\")"
        }
        if let maxAge {
            logicDD += "\n$1.setHeader(key: HTTPResponseHeader.accessControlMaxAgeRawName, value: \"" + String(maxAge) + "\")"
        }
        self.logic = { _, _ in }
        self.logicDebugDescription = logicDD + " }"
    }

    public init(_ logic: @escaping @Sendable (inout any RequestProtocol, inout any DynamicResponseProtocol) -> Void) {
        self.logic = logic
        self.logicDebugDescription = "{ _, _ in }"
    }

    @inlinable
    public mutating func load() {
    }

    @inlinable
    public func handle(request: inout any RequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        guard request.header(forKey: HTTPRequestHeader.originRawName) != nil else { return true }
        try await logic(&request, &response)
        return true
    }

    public var debugDescription: String {
        "DynamicCORSMiddleware \(logicDebugDescription)"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicCORSMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var allowedOrigin = CORSMiddlewareAllowedOrigin.originBased
        var allowedHeaders:Set<HTTPRequestHeader> = [.accept, .authorization, .contentType, .origin]
        var allowedMethods:Set<HTTPRequestMethod> = [.get, .post, .put, .options, .delete, .patch]
        var allowCredentials = false
        var maxAge:Int? = 600
        var exposedHeaders:Set<HTTPRequestHeader>? = nil
        for argument in function.arguments {
            switch argument.label?.text {
            case "allowedOrigin":
                if let decl = argument.expression.memberAccess?.declName.baseName.text {
                    switch decl {
                    case "all": allowedOrigin = .all
                    case "none": allowedOrigin = .none
                    case "originBased": allowedOrigin = .originBased
                    default: break
                    }
                } else if let function = argument.expression.functionCall {
                    switch function.calledExpression.memberAccess?.declName.baseName.text {
                    case "any": allowedOrigin = .any(Set(function.arguments.first!.expression.array!.elements.map({ $0.expression.stringLiteral!.string })))
                    case "custom": allowedOrigin = .custom(function.arguments.first!.expression.stringLiteral!.string)
                    default: break
                    }
                }
            case "allowedHeaders":
                allowedHeaders = Set(argument.expression.array!.elements.compactMap({ HTTPRequestHeader(expr: $0.expression) }))
            case "allowedMethods":
                allowedMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequestMethod(expr: $0.expression) }))
            case "allowCredentials":
                allowCredentials = argument.expression.booleanIsTrue
            case "maxAge":
                if let s = argument.expression.integerLiteral?.literal.text {
                    maxAge = Int(s)
                } else if argument.expression.is(NilLiteralExprSyntax.self) {
                    maxAge = nil
                }
            case "exposedHeaders":
                guard let values = argument.expression.array?.elements.compactMap({ HTTPRequestHeader(expr: $0.expression) }) else { break }
                exposedHeaders = Set(values)
            default:
                break
            }
        }
        return Self(allowedOrigin: allowedOrigin, allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, allowCredentials: allowCredentials, exposedHeaders: exposedHeaders, maxAge: maxAge)
    }
}
#endif