//
//  Route.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax

// MARK: RouteProtocol
/// The core Route protocol that powers Destiny's Routing.
public protocol RouteProtocol {
    /// The http method of this route.
    var method : HTTPRequest.Method { get }
    /// The path of this route.
    var path : [String] { get }
    /// The default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status : HTTPResponse.Status? { get }
    /// The default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType : HTTPField.ContentType { get }
}

// MARK: StaticRouteProtocol
public protocol StaticRouteProtocol : RouteProtocol {
    var result : RouteResult { get }

    /// Returns a string representing a complete HTTP Response.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - middleware: The static middleware the associated `Router` uses.
    /// - Throws: any error; if thrown: a compile error is thrown describing the issue
    func response(version: String, middleware: [StaticMiddlewareProtocol]) throws -> String

    /// Parsing logic for this static route. Computed at compile time.
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    static func parse(_ function: FunctionCallExprSyntax) -> Self
}

// MARK: DynamicRouteProtocol
public protocol DynamicRouteProtocol : RouteProtocol {
    /// The default response computed by this route's method & path, and any corresponding static middleware.
    var defaultResponse : DynamicResponse { get }
    /// Whether or not this dynamic route responds asynchronously or synchronously.
    var isAsync : Bool { get }
    /// A string representation of the synchronous handler logic, required when parsing from the router macro.
    var handlerLogic : String { get }
    /// A string representation of the asynchronous handler logic, required when parsing from the router macro.
    var handlerLogicAsync : String { get }

    /// Returns a string representing an initialized route responder conforming to `DynamicRouteResponseProtocol`.
    /// 
    /// Loads the route responder in a `Router`'s dynamic route responses. Computed at compile time.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - logic: The string representation of the synchronous/asynchronous handler logic this route uses.
    func responder(version: String, logic: String) -> String

    /// Parsing logic for this dynamic route. Computed at compile time.
    /// - Warning: You need to assign `handlerLogic` or `handlerLogicAsync` properly.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - middleware: The static middleware the associated `Router` uses.
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    static func parse(version: String, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self
}

// MARK: RouteResult
public enum RouteResult : Sendable {
    case string(String)
    case bytes([UInt8])
    case json(Encodable & Sendable)
    case error(Error)

    public var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
            case .json(let encodable): return (try? JSONEncoder().encode(encodable).count) ?? 0
            case .error(let error): return "\(error)".count
        }
    }

    @inlinable
    package func string() throws -> String {
        switch self {
            case .string(let string): return string
            case .bytes(let bytes): return bytes.map({ "\($0)" }).joined()
            case .json(let encodable):
                do {
                    let data:Data = try JSONEncoder().encode(encodable)
                    return String(data: data, encoding: .utf8) ?? "{\"error\":500\",\"reason\":\"couldn't convert JSON encoded Data to UTF-8 String\"}"
                } catch {
                    return "{\"error\":500,\"reason\":\"\(error)\"}"
                }
            case .error(let error): return "\(error)"
        }
    }
}

// MARK: SwiftSyntax Misc
extension SyntaxProtocol {
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var booleanLiteral : BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}