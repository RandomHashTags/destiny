//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
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

public typealias DestinyRoutePathType = StackString64

// MARK: SwiftSyntax Misc
package extension ExprSyntax {
    var macroExpansion : MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var booleanLiteral : BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    var integerLiteral : IntegerLiteralExprSyntax? { self.as(IntegerLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

package extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}