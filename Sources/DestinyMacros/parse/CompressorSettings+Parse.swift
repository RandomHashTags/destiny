
#if Compression

import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

extension CompressorSettings {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self {
        var settings = Self()
        guard let function = expr.functionCall else { return settings }
        for arg in function.arguments {
            switch arg.label?.text {
            case "contentTypePrefixWhitelist":
                settings.contentTypePrefixWhitelist = arg.expression.stringLiteralString(context: context)
            case "contentTypeWhitelist":
                guard let array = arg.expression.arrayElements(context: context)?.compactMap({ $0.expression.stringLiteralString(context: context) }) else { continue }
                settings.contentTypeWhitelist = Set(array)
            case "contentTypePrefixBlacklist":
                settings.contentTypePrefixBlacklist = arg.expression.stringLiteralString(context: context)
            case "contentTypeBlacklist":
                guard let array = arg.expression.arrayElements(context: context)?.compactMap({ $0.expression.stringLiteralString(context: context) }) else { continue }
                settings.contentTypeBlacklist = Set(array)
            default:
                break
            }
        }
        return settings
    }
}

#endif