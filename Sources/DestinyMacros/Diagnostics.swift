
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DiagnosticMsg
struct DiagnosticMsg: DiagnosticMessage {
    let message:String
    let diagnosticID:MessageID
    let severity:DiagnosticSeverity

    init(id: String, message: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "DestinyMacros", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}

// MARK: General
extension DiagnosticMsg {
    static func unhandled(node: some SyntaxProtocol, notes: String = "") -> Diagnostic {
        .init(node: node, message: DiagnosticMsg(id: "unhandled", message: "Unhandled\(notes.isEmpty ? "" : "; \(notes)")", severity: .warning))
    }
    static func httpCookieError(node: some SyntaxProtocol, error: HTTPCookieError) -> Diagnostic {
        .init(node: node, message: DiagnosticMsg(id: "httpCookieError", message: "\(error)"))
    }
}

// MARK: Expectations
extension DiagnosticMsg {
    static func expectedArrayExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedArrayExpr", message: "Expected array expression; got \(expr.kind)"))
    }
    static func expectedFunctionCallExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedFunctionCallExpr", message: "Expected function call expression; got \(expr.kind)"))
    }
    static func expectedMemberAccessExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedMemberAccessExpr", message: "Expected member access expression; got \(expr.kind)"))
    }
    static func expectedFunctionCallOrMemberAccessExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedFunctionCallOrMemberAccessExpr", message: "Expected function call or member access expression; got \(expr.kind)"))
    }
    static func expectedStringLiteral(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedStringLiteral", message: "Expected string literal; got \(expr.kind)"))
    }
    static func expectedStringLiteralOrMemberAccess(expr: some ExprSyntaxProtocol) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "expectedStringLiteralOrMemberAccess", message: "Expected string literal or member access; got \(expr.kind)"))
    }
    static func stringLiteralContainsIllegalCharacter(expr: some ExprSyntaxProtocol, char: String) -> Diagnostic {
        .init(node: expr, message: DiagnosticMsg(id: "stringLiteralContainsIllegalCharacter", message: "String literal contains illegal character: \"\(char)\""))
    }
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
    package func arrayElements(context: some MacroExpansionContext) -> ArrayElementListSyntax? {
        guard let elements = array?.elements else {
            context.diagnose(DiagnosticMsg.expectedArrayExpr(expr: self))
            return nil
        }
        return elements
    }
    package func stringLiteralString(context: some MacroExpansionContext) -> String? {
        guard let s = stringLiteral?.string else {
            context.diagnose(DiagnosticMsg.expectedStringLiteral(expr: self))
            return nil
        }
        return s
    }
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