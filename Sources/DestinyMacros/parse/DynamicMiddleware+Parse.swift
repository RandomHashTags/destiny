
#if NonEmbedded

import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

extension DynamicMiddleware {
    public static func parse(
        context: some MacroExpansionContext,
        _ function: FunctionCallExprSyntax
    ) -> Self {
        var logic = "\(function.trailingClosure?.debugDescription ?? "{ _, _ in }")"
        for arg in function.arguments {
            if let _ = arg.label?.text {
            } else {
                logic = "\(arg.expression)"
            }
        }
        var middleware = DynamicMiddleware { _, _ in }
        middleware.logic = "\(logic)"
        return middleware
    }
}

#endif