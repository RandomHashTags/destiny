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
    func response(version: String, middleware: [StaticMiddlewareProtocol]) throws -> String
}

// MARK: DynamicRouteProtocol
public protocol DynamicRouteProtocol : RouteProtocol {
    func response(middleware: [DynamicMiddlewareProtocol], request: borrowing Request) -> String
}

// MARK: DynamicResponse
public struct DynamicResponse : Sendable {
    public var version:String
    public var status:HTTPResponse.Status
    public var headers:[String:String]
    public var result:RouteResult

    public init(
        version: String,
        status: HTTPResponse.Status,
        headers: [String:String],
        result: RouteResult
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.result = result
    }

    package func response() throws -> String {
        let result_string:String = try result.string()
        var string:String = version + " \(status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        let content_length:Int = result_string.count - result_string.ranges(of: "\\").count
        string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
        return string + "\\r\\n\\r\\n" + result_string
    }
}

// MARK: RouteResult
public enum RouteResult : Sendable {
    case string(String)
    case bytes([UInt8])
    case json(Encodable & Sendable)

    public var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
            case .json(let encodable): return (try? JSONEncoder().encode(encodable).count) ?? 0
        }
    }

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