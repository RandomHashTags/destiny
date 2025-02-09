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
    values: [String:HTTPFieldContentTypeDetails]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPFieldContentType")

struct HTTPFieldContentTypeDetails {
    let httpValue:String
    let fileExtensions:Set<String>

    init(_ httpValue: String, fileExtensions: Set<String> = []) {
        self.httpValue = httpValue
        self.fileExtensions = fileExtensions
    }
}

#if canImport(Foundation)
@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }
#endif

public typealias DestinyRoutePathType = SIMD64<UInt8>

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax




// MARK: SwiftDiagnostics
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

extension Diagnostic {
    package static func spacesNotAllowedInRoutePath(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "spacesNotAllowedInRoutePath", message: "Spaces aren't allowed in route paths.")))
    }
    package static func routeStatusNotImplemented(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routeStatusNotImplemented", message: "Route's status is \".notImplemented\".", severity: .warning)))
    }
}

// MARK: SwiftSyntax Misc
extension ExprSyntaxProtocol {
    package var macroExpansion : MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    package var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    package var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    package var booleanLiteral : BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    package var integerLiteral : IntegerLiteralExprSyntax? { self.as(IntegerLiteralExprSyntax.self) }
    package var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    package var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    package var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    package var string : String { "\(segments)" }
}
#endif