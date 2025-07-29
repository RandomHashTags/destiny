
import SwiftCompilerPlugin
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
        self.diagnosticID = MessageID(domain: "DestinyUtilityMacros", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}


@main
struct DestinyUtilityMacros: CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
        InlineArrayMacro.self,
        HTTPResponseStatusesMacro.self,
        HTTPRequestMethods.self
    ]
}

// MARK: SwiftSyntax Misc
extension SyntaxProtocol {
    var functionCall: FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral: StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var booleanLiteral: BooleanLiteralExprSyntax? { self.as(BooleanLiteralExprSyntax.self) }
    var memberAccess: MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array: ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary: DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string: String { "\(segments)" }
}