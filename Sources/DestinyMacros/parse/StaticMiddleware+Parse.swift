
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension StaticMiddleware {
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: SwiftSyntax expression that represents this middleware at compile time.
    public static func parse(
        context: some MacroExpansionContext,
        _ function: FunctionCallExprSyntax
    ) -> CompiledStaticMiddleware {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:[any HTTPRequestMethodProtocol]? = nil
        var handlesStatuses:Set<HTTPResponseStatus.Code>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus.Code? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders = HTTPHeaders()
        var appliesCookies = [HTTPCookie]()
        var excludedRoutes = Set<String>()
        for arg in function.arguments {
            switch arg.label?.text {
            case "handlesVersions":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesVersions = Set(array.compactMap({ HTTPVersion.parse(context: context, expr: $0.expression) }))
            case "handlesMethods":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesMethods = array.compactMap({ HTTPRequestMethod.parse(expr: $0.expression) })
            case "handlesStatuses":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesStatuses = Set(array.compactMap({ HTTPResponseStatus.parseCode(expr: $0.expression) }))
            case "handlesContentTypes":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesContentTypes = Set(array.compactMap({ HTTPMediaType.parse(memberName: "\($0.expression.memberAccess!.declName.baseName.text)") }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(context: context, expr: arg.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus.parseCode(expr: arg.expression)
            case "appliesContentType":
                guard let memberName = arg.expression.memberAccess?.declName.baseName.text else {
                    context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: arg.expression))
                    break
                }
                appliesContentType = HTTPMediaType.parse(memberName: memberName)
            case "appliesHeaders":
                appliesHeaders = HTTPRequestHeader.parse(context: context, arg.expression)
            case "appliesCookies":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                appliesCookies = array.compactMap({ HTTPCookie.parse(context: context, expr: $0.expression) })
            case "excludedRoutes":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                excludedRoutes = Set(array.compactMap({ $0.expression.stringLiteralString(context: context) }))
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        return CompiledStaticMiddleware(
            handlesVersions: handlesVersions,
            handlesMethods: handlesMethods,
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes,
            appliesVersion: appliesVersion,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: appliesHeaders,
            appliesCookies: appliesCookies,
            excludedRoutes: excludedRoutes
        )
    }
}