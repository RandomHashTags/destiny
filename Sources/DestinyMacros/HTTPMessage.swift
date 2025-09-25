
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

#if MediaTypes
import MediaTypes
import MediaTypesSwiftSyntax
#endif

#if NonEmbedded
import DestinyDefaultsNonEmbedded
#endif

enum HTTPMessage: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        var version = HTTPVersion.v1_1
        var status:HTTPResponseStatus.Code = 501 // not implemented
        var headers = HTTPHeaders()
        var body:(any ResponseBodyProtocol)? = nil
        var contentType:String? = nil
        var charset:Charset? = nil
        var cookies = [HTTPCookie]()
        for arg in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            switch arg.label?.text {
            case "version":
                version = HTTPVersion.parse(context: context, expr: arg.expression) ?? version
            case "status":
                status = HTTPResponseStatus.parseCode(context: context, expr: arg.expression) ?? status
            case "headers":
                headers = HTTPHeaders.parse(context: context, arg.expression)
            case "body":
                body = ResponseBody.parse(context: context, expr: arg.expression)
            case "contentType":
                contentType = arg.expression.stringLiteralString(context: context) ?? contentType
            #if MediaTypes
            case "mediaType":
                guard let s = MediaType.parse(context: context, expr: arg.expression)?.template else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg))
                    break
                }
                contentType = s
            #endif
            case "charset":
                charset = Charset(expr: arg.expression)
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        var response = ""
        #if GenericHTTPMessage
        //response = genericResponse(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
        #endif
        #if NonEmbedded
        response = nonEmbeddedResponse(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
        #endif
        response = "\"\(response)\""
        return ["\(raw: response)"]
    }

    #if GenericHTTPMessage
    private static func genericResponse(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (some ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) -> String {
        GenericHTTPResponseMessage(
            version: version,
            status: status,
            headers: headers,
            cookies: cookies,
            body: body,
            contentType: contentType,
            charset: charset
        ).string(escapeLineBreak: true)
    }
    #endif

    #if NonEmbedded
    private static func nonEmbeddedResponse(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) -> String {
        return HTTPResponseMessage(
            version: version,
            status: status,
            headers: headers,
            cookies: cookies,
            body: body,
            contentType: contentType,
            charset: charset
        ).string(escapeLineBreak: true)
    }
    #endif
}