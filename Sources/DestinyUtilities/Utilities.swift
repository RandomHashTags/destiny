//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(Foundation)
import Foundation
#endif

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

@freestanding(declaration, names: arbitrary)
macro HTTPFieldContentType(
    category: String,
    values: [String:String]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPFieldContentType")

#if canImport(Foundation)
@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }
#endif

public typealias DestinyRoutePathType = SIMD64<UInt8>

// MARK: DiagnosticMsg
package struct DiagnosticMsg : DiagnosticMessage {
    package let message:String
    package let diagnosticID:MessageID
    package let severity:DiagnosticSeverity

    package init(id: String, message: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "DestinyUtilities", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg : FixItMessage {
    package var fixItID : MessageID { diagnosticID }
}

package extension Diagnostic {
    static func spacesNotAllowedInRoutePath(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "spacesNotAllowedInRoutePath", message: "Spaces aren't allowed in route paths.")))
    }
    static func routeStatusNotImplemented(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routeStatusNotImplemented", message: "Route's status is \".notImplemented\".", severity: .warning)))
    }
}

// MARK: SwiftSyntax Misc
package extension ExprSyntaxProtocol {
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