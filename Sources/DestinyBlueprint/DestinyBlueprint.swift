
#if canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
#endif

@freestanding(expression)
public macro inlineArray<let count: Int>(_ input: String) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(expression)
public macro inlineArray<let count: Int>(_ input: Int) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(expression)
public macro inlineArray<let count: Int>(count: Int, _ input: String) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(declaration, names: arbitrary)
macro httpResponseStatuses(
    _ entries: [(memberName: String, code: Int, phrase: String)]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPResponseStatusesMacro")


#if canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax




// MARK: SwiftDiagnostics
package struct DiagnosticMsg: DiagnosticMessage {
    package let message:String
    package let diagnosticID:MessageID
    package let severity:DiagnosticSeverity

    package init(id: String, message: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "DestinyBlueprint", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg: FixItMessage {
    package var fixItID: MessageID { diagnosticID }
}

extension Diagnostic {
    package static func spacesNotAllowedInRoutePath(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "spacesNotAllowedInRoutePath", message: "Spaces aren't allowed in route paths.")))
    }
    package static func routeResponseStatusNotImplemented(context: some MacroExpansionContext, node: SyntaxProtocol) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routeResponseStatusNotImplemented", message: "Route's response status is \".notImplemented\".", severity: .warning)))
    }
}

// MARK: SwiftSyntax Misc
extension ExprSyntaxProtocol {
    package var macroExpansion: MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    package var functionCall: FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    package var stringLiteral: StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    package var booleanLiteral: BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    package var integerLiteral: IntegerLiteralExprSyntax? { self.as(IntegerLiteralExprSyntax.self) }
    package var memberAccess: MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    package var array: ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    package var dictionary: DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension ExprSyntaxProtocol {
    package var booleanIsTrue: Bool {
        booleanLiteral?.isTrue ?? false
    }
}
extension BooleanLiteralExprSyntax {
    package var isTrue: Bool {
        literal.text == "true"
    }
}

extension StringLiteralExprSyntax {
    package var string: String { "\(segments)" }
}
#endif