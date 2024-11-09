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
    private let tokens:[SIMD64<UInt8>]
    private let headersBeginIndex:Int
    public let startLine:DestinyRoutePathType
    public let methodSIMD:StackString8
    public let uri:DestinyRoutePathType
    public let version:HTTPVersion
    //public let body:String

    public lazy var method : HTTPRequest.Method? = {
        return HTTPRequest.Method.parse(methodSIMD)
    }()
    public lazy var path : [String] = {
        return uri.splitSIMD(separator: 47).map({ $0.string() }) // 47 = /
    }()

    public lazy var headers : [StackString64:String] = {
        var dictionary:[StackString64:String] = [:]
        return dictionary
    }()

    public init?(
        tokens: [SIMD64<UInt8>]
    ) {
        self.tokens = tokens
        guard var startLine:SIMD64<UInt8> = tokens.first else { return nil }
        let values:[SIMD64<UInt8>] = startLine.splitSIMD(separator: 32) // space
        guard let versionSIMD:SIMD64<UInt8> = values.get(2) else { return nil }
        let first_carriage_return_index:Int = startLine.leadingNonByteCount(byte: 13) // \r
        headersBeginIndex = first_carriage_return_index + 2
        //print("Utilities;Request;init;first_carriage_return_index=\(first_carriage_return_index);startLine=\(startLine.string())")
        //print("shifted bytes=\((startLine &<< UInt8((first_carriage_return_index + 2) * 8)))")
        startLine.keepLeading(first_carriage_return_index)
        self.startLine = startLine.lowHalf
        methodSIMD = values[0].lowHalf.lowHalf.lowHalf
        uri = values[1].lowHalf
        version = HTTPVersion(versionSIMD.lowHalf)
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