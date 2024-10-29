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
public protocol RouteProtocol {
    var method : HTTPRequest.Method { get }
    var path : String { get }
    var status : HTTPResponse.Status? { get }
    var result : RouteResult { get }

    static func parse(_ function: FunctionCallExprSyntax) -> Self
}

// MARK: StaticRouteProtocol
public protocol StaticRouteProtocol : RouteProtocol {
    func response(version: String, middleware: [StaticMiddlewareProtocol]) -> String
}

// MARK: DynamicRouteProtocol
public protocol DynamicRouteProtocol : RouteProtocol {
    func response(middleware: [DynamicMiddlewareProtocol], request: borrowing Request) -> String
}

// MARK: DynamicResponse
public struct DynamicResponse {
    public var status:HTTPResponse.Status
    public var result:RouteResult
    public var headers:[String:String]

    public init(
        status: HTTPResponse.Status,
        result: RouteResult,
        headers: [String:String]
    ) {
        self.status = status
        self.result = result
        self.headers = headers
    }
}

// MARK: RouteResult
public enum RouteResult {
    case string(String)
    case bytes([UInt8])
    case json(Encodable)

    var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
            case .json(let encodable): return (try? JSONEncoder().encode(encodable).count) ?? 0
        }
    }
}

// MARK: SwiftSyntax Misc
extension SyntaxProtocol {
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}