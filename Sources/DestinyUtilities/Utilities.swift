//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

public typealias DestinyRoutePathType = StackString32

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:[String]
    public let version:String
    public let headers:[String:String]
    public let body:String

    public init(
        method: HTTPRequest.Method,
        path: [String],
        version: String,
        headers: [String:String],
        body: String
    ) {
        self.method = method
        self.path = path
        self.version = version
        self.headers = headers
        self.body = body
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