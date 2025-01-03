//
//  DynamicCORSMiddleware.swift
//
//
//  Created by Evan Anderson on 12/8/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicCORSMiddleware
/// The default dynamic `CORSMiddlewareProtocol` that enables CORS for dynamic requests.
/// [Read more](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
public struct DynamicCORSMiddleware : CORSMiddlewareProtocol, DynamicMiddlewareProtocol {
    public let logic:@Sendable (inout RequestProtocol, inout DynamicResponseProtocol) async throws -> Void
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
        allowedHeaders: Set<HTTPField.Name> = [.accept, .authorization, .contentType, .origin],
        allowedMethods: Set<HTTPRequest.Method> = [.get, .post, .put, .options, .delete, .patch],
        allowCredentials: Bool = false,
        exposedHeaders: Set<HTTPField.Name>? = nil,
        maxAge: Int? = 3600 // one hour
    ) {
        var logicDD:String = "{\n"
        switch allowedOrigin {
        case .all:
            logicDD += "$1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = \"*\""
        case .any(let origins):
            logicDD += "if let origin:String = $0.headers[HTTPField.Name.origin.rawName], (\(origins) as Set<String>).contains(origin) { $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = origin }"
        case .custom(let s):
            logicDD += "$1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = \"" + s + "\""
        case .none:
            break
        case .originBased:
            logicDD += "$1.headers[HTTPField.Name.vary.rawName, default: \"\"] = \"origin\""
            logicDD += "\nif let origin:String = $0.headers[HTTPField.Name.origin.rawName] { $1.headers[HTTPField.Name.accessControlAllowOrigin.rawName] = origin }"
        }

        let allowedHeaders:String = allowedHeaders.map({ $0.rawName  }).joined(separator: ",")
        let allowedMethods:String = allowedMethods.map({ $0.rawValue }).joined(separator: ",")
        logicDD += "\n$1.headers[HTTPField.Name.accessControlAllowHeaders.rawName] = \"" + allowedHeaders + "\""
        logicDD += "\n$1.headers[HTTPField.Name.accessControlAllowMethods.rawName] = \"" + allowedMethods + "\""
        if allowCredentials {
            logicDD += "\n$1.headers[HTTPField.Name.accessControlAllowCredentials.rawName] = \"true\""
        }
        if let exposedHeaders:String = exposedHeaders?.map({ $0.rawName }).joined(separator: ",") {
            logicDD += "\n$1.headers[HTTPField.Name.accessControlExposeHeaders.rawName] = \"" + exposedHeaders + "\""
        }
        if let maxAge:Int = maxAge {
            logicDD += "\n$1.headers[HTTPField.Name.accessControlMaxAge.rawName] = \"" + String(maxAge) + "\""
        }
        self.logic = { _, _ in }
        self.logicDebugDescription = logicDD + " }"
    }

    public init(_ logic: @escaping @Sendable (inout RequestProtocol, inout DynamicResponseProtocol) -> Void) {
        self.logic = logic
        self.logicDebugDescription = "{ _, _ in }"
    }

    @inlinable
    public mutating func load() {
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool {
        guard request.headers.has(HTTPField.Name.origin.rawName) else { return true }
        try await logic(&request, &response)
        return true
    }

    public var debugDescription : String { "DynamicCORSMiddleware \(logicDebugDescription)" }

}

// MARK: Parse
public extension DynamicCORSMiddleware {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var allowedOrigin:CORSMiddlewareAllowedOrigin = .originBased
        var allowedHeaders:Set<HTTPField.Name> = [.accept, .authorization, .contentType, .origin]
        var allowedMethods:Set<HTTPRequest.Method> = [.get, .post, .put, .options, .delete, .patch]
        var allowCredentials:Bool = false
        var maxAge:Int? = 600
        var exposedHeaders:Set<HTTPField.Name>? = nil
        for argument in function.arguments {
            switch argument.label!.text {
            case "allowedOrigin":
                if let decl:String = argument.expression.memberAccess?.declName.baseName.text {
                    switch decl {
                    case "all": allowedOrigin = .all
                    case "none": allowedOrigin = .none
                    case "originBased": allowedOrigin = .originBased
                    default: break
                    }
                } else if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                    switch function.calledExpression.memberAccess!.declName.baseName.text {
                    case "any": allowedOrigin = .any(Set(function.arguments.first!.expression.array!.elements.map({ $0.expression.stringLiteral!.string })))
                    case "custom": allowedOrigin = .custom(function.arguments.first!.expression.stringLiteral!.string)
                    default: break
                    }
                }
            case "allowedHeaders":
                allowedHeaders = Set(argument.expression.array!.elements.compactMap({
                    HTTPField.Name(caseName: $0.expression.memberAccess!.declName.baseName.text)
                }))
            case "allowedMethods":
                allowedMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequest.Method(expr: $0.expression) }))
            case "allowCredentials":
                allowCredentials = argument.expression.booleanLiteral?.literal.text == "true"
            case "maxAge":
                if let s:String = argument.expression.integerLiteral?.literal.text {
                    maxAge = Int(s)
                } else if argument.expression.is(NilLiteralExprSyntax.self) {
                    maxAge = nil
                }
            case "exposedHeaders":
                guard let values:[HTTPField.Name] = argument.expression.array?.elements.compactMap({ HTTPField.Name(caseName: $0.expression.memberAccess!.declName.baseName.text) }) else { break }
                exposedHeaders = Set(values)
            default:
                break
            }
        }
        return Self(allowedOrigin: allowedOrigin, allowedHeaders: allowedHeaders, allowedMethods: allowedMethods, allowCredentials: allowCredentials, exposedHeaders: exposedHeaders, maxAge: maxAge)
    }
}