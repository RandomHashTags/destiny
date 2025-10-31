
import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPResponseMessageHead {
    public static func parse(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> HTTPResponseMessageHead? {
        guard let function = expr.functionCall else {
            context.diagnose(DiagnosticMsg.unhandled(node: expr))
            return nil
        }
        var head = Self.default
        for arg in function.arguments {
            switch arg.label?.text {
            case "headers":
                head.headers = .parse(context: context, arg.expression)

            #if HTTPCookie
            case "cookies":
                guard let elements = arg.expression.arrayElements(context: context) else { break }
                head.cookies = elements.compactMap({ HTTPCookie.parse(context: context, expr: $0.expression) })
            #endif

            case "status":
                guard let parsed = HTTPResponseStatus.parseCode(context: context, expr: arg.expression) else {
                    break
                }
                head.status = parsed
            case "version":
                guard let parsed = HTTPVersion.parse(context: context, expr: arg.expression) else { break }
                head.version = parsed
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        return head
    }
}