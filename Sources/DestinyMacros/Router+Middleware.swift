
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Parse
extension Router {
    private static func precheck(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
    ) -> String? {
        guard let text = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else {
            context.diagnose(DiagnosticMsg.unhandled(node: function))
            return nil
        }
        guard text.contains("Middleware") else {
            context.diagnose(DiagnosticMsg.unhandled(node: function, notes: "type `\(text)` does not contain \"Middleware\", but is required to work properly; ignoring"))
            return nil
        }
        return text
    }

    static func parseMiddleware(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        storage: inout Storage
    ) {
        guard let text = precheck(context: context, function: function) else { return }
        if text.contains("Static") {
            parseStaticMiddleware(context: context, function: function, storage: &storage)
        } else {
            parseDynamicMiddleware(context: context, function: function, storage: &storage)
        }
    }


    static func parseStaticMiddleware(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        storage: inout Storage
    ) {
        guard let text = precheck(context: context, function: function) else { return }
        guard text.contains("Static") else {
            context.diagnose(DiagnosticMsg.unhandled(node: function))
            return
        }
        storage.staticMiddleware.append(StaticMiddleware.parse(context: context, function))
    }

    static func parseDynamicMiddleware(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        storage: inout Storage
    ) {
        guard let text = precheck(context: context, function: function) else { return }
        guard text.contains("Dynamic") else {
            context.diagnose(DiagnosticMsg.unhandled(node: function))
            return
        }
        if text == "DynamicMiddleware" {
            storage.upgradeExistentialDynamicMiddleware.append(function)
        } else {
            storage.dynamicMiddleware.append(function)
        }
    }
}