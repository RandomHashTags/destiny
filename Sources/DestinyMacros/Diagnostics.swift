
#if canImport(SwiftDiagnostics) && canImport(SwiftSyntax)

import SwiftDiagnostics
import SwiftSyntax

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
    static func unhandled(node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: node, message: DiagnosticMsg(id: "unhandled", message: "Unhandled", severity: .warning))
    }
}

// MARK: Expectations
extension DiagnosticMsg {
    static func expectedArrayExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedArrayExpr", message: "Expected array expression; got \(expr.kind)"))
    }
    static func expectedFunctionCallExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedFunctionCallExpr", message: "Expected function call expression; got \(expr.kind)"))
    }
    static func expectedMemberAccessExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedMemberAccessExpr", message: "Expected member access expression; got \(expr.kind)"))
    }
    static func expectedFunctionCallOrMemberAccessExpr(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedFunctionCallOrMemberAccessExpr", message: "Expected function call or member access expression; got \(expr.kind)"))
    }
    static func expectedStringLiteral(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedStringLiteral", message: "Expected string literal; got \(expr.kind)"))
    }
    static func expectedStringLiteralOrMemberAccess(expr: some ExprSyntaxProtocol) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "expectedStringLiteralOrMemberAccess", message: "Expected string literal or member access; got \(expr.kind)"))
    }
    static func stringLiteralContainsIllegalCharacter(expr: some ExprSyntaxProtocol, char: String) -> Diagnostic {
        Diagnostic(node: expr, message: DiagnosticMsg(id: "stringLiteralContainsIllegalCharacter", message: "String literal contains illegal character: \"\(char)\""))
    }
}

#endif