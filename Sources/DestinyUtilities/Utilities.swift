//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax

@attached(member, names: arbitrary)
macro HTTPFieldContentTypes(
    application: [String:String],
    audio: [String:String],
    font: [String:String],
    haptics: [String:String],
    image: [String:String],
    message: [String:String],
    model: [String:String],
    multipart: [String:String],
    text: [String:String],
    video: [String:String]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPFieldContentTypes")

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

public typealias DestinyRoutePathType = StackString32

// MARK: Request
public struct Request : ~Copyable {
    public let startLine:DestinyRoutePathType
    public let methodSIMD:StackString8
    public let uri:DestinyRoutePathType
    public let version:HTTPVersion
    //public let headers:[String:String]
    //public let headers:[StackString64:String]
    //public let body:String

    public lazy var method : HTTPRequest.Method? = {
        return HTTPRequest.Method.parse(methodSIMD)
    }()
    public lazy var path : [String] = {
        return uri.splitSIMD(separator: 47).map({ $0.string() })
    }()

    public init(
        tokens: [SIMD64<UInt8>]
    ) {
        var startLine:SIMD64<UInt8> = tokens[0]
        let values:[SIMD64<UInt8>] = startLine.splitSIMD(separator: 32) // space
        let first_back_slash_index:Int = startLine.leadingNonByteCount(byte: 13) // \r
        startLine.keep(first_back_slash_index)
        self.startLine = startLine.lowHalf
        methodSIMD = values[0].lowHalf.lowHalf.lowHalf
        uri = values[1].lowHalf
        version = HTTPVersion(values[2].lowHalf)
    }

    public var description : String {
        return startLine.string() + " (" + methodSIMD.string() + "; " + uri.string() + ";" + version.token.string() + ")"
    }
}

// MARK: SwiftSyntax Misc
package extension SyntaxProtocol {
    var macroExpansion : MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var booleanLiteral : BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

package extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}