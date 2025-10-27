
#if StaticMiddleware

import DestinyDefaults
import DestinyEmbedded
import SwiftSyntax
import SwiftSyntaxMacros

#if MediaTypes
import MediaTypes
import MediaTypesSwiftSyntax
#endif

// MARK: SwiftSyntax
extension StaticMiddleware {
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: SwiftSyntax expression that represents this middleware at compile time.
    public static func parse(
        context: some MacroExpansionContext,
        _ function: FunctionCallExprSyntax
    ) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:[HTTPRequestMethod]? = nil
        var handlesStatuses:Set<HTTPResponseStatus.Code>? = nil
        var handlesContentTypes:Set<String>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus.Code? = nil
        var appliesContentType:String? = nil
        var appliesHeaders = HTTPHeaders()

        #if HTTPCookie
        var appliesCookies = [HTTPCookie]()
        #endif

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
                handlesStatuses = Set(array.compactMap({ HTTPResponseStatus.parseCode(context: context, expr: $0.expression) }))
            case "handlesContentTypes":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesContentTypes = Set(array.compactMap({
                    if let s = $0.expression.memberAccess?.declName.baseName.text {
                        return s
                    } else {
                        return $0.expression.stringLiteralString(context: context)
                    }
                }))
            #if MediaTypes
            case "handlesMediaTypes":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                handlesContentTypes = Set(array.compactMap({
                    guard let s = MediaType.parse(context: context, expr: $0.expression)?.template else {
                        context.diagnose(DiagnosticMsg.unhandled(node: $0))
                        return nil
                    }
                    return s
                }))
            #endif
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(context: context, expr: arg.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus.parseCode(context: context, expr: arg.expression)
            case "appliesContentType":
                appliesContentType = arg.expression.stringLiteralString(context: context) ?? appliesContentType

            #if MediaTypes
            case "appliesMediaType":
                guard let s = MediaType.parse(context: context, expr: arg.expression)?.template else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg))
                    break
                }
                appliesContentType = s
            #endif

            case "appliesHeaders":
                appliesHeaders = HTTPHeaders.parse(context: context, arg.expression)

            #if HTTPCookie
            case "appliesCookies":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                appliesCookies = array.compactMap({ HTTPCookie.parse(context: context, expr: $0.expression) })
            #endif

            case "excludedRoutes":
                guard let array = arg.expression.arrayElements(context: context) else { break }
                excludedRoutes = Set(array.compactMap({ $0.expression.stringLiteralString(context: context) }))
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        #if HTTPCookie
        return .init(
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
        #else
        return .init(
            handlesVersions: handlesVersions,
            handlesMethods: handlesMethods,
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes,
            appliesVersion: appliesVersion,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: appliesHeaders,
            excludedRoutes: excludedRoutes
        )
        #endif
    }
}

#endif