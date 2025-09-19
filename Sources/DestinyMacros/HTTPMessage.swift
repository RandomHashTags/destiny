
import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPMessage: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        var version = HTTPVersion.v1_1
        var status = HTTPStandardResponseStatus.notImplemented.code
        var headers = HTTPHeaders()
        var body:(any ResponseBodyProtocol)? = nil
        var contentType:HTTPMediaType? = nil
        var charset:Charset? = nil
        var cookies = [HTTPCookie]()
        for child in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            switch child.label?.text {
            case "version":
                version = HTTPVersion.parse(context: context, expr: child.expression) ?? version
            case "status":
                status = HTTPResponseStatus.parseCode(expr: child.expression) ?? status
            case "headers":
                headers = HTTPHeaders.parse(context: context, child.expression)
            case "body":
                body = ResponseBody.parse(context: context, expr: child.expression)
            case "contentType":
                contentType = HTTPMediaType.parse(context: context, expr: child.expression) ?? contentType
            case "charset":
                charset = Charset(expr: child.expression)
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: child))
            }
        }
        var response = HTTPResponseMessage(
            version: version,
            status: status,
            headers: headers,
            cookies: cookies,
            body: body,
            contentType: contentType,
            charset: charset
        ).string(escapeLineBreak: true)
        response = "\"" + response + "\""
        return ["\(raw: response)"]
    }
}