
import DestinyBlueprint
import DestinyDefaults
import OrderedCollections
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
    ) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:[any HTTPRequestMethodProtocol]? = nil
        var handlesStatuses:Set<HTTPResponseStatus.Code>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus.Code? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders = OrderedDictionary<String, String>()
        var appliesCookies = [Cookie]()
        var excludedRoutes = Set<String>()
        for argument in function.arguments {
            switch argument.label?.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = argument.expression.array?.elements.compactMap({ HTTPRequestMethod.parse(expr: $0.expression) })
            case "handlesStatuses":
                handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponseStatus.parseCode(expr: $0.expression) }))
            case "handlesContentTypes":
                handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaType.parse(memberName: "\($0.expression.memberAccess!.declName.baseName.text)") }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(argument.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus.parseCode(expr: argument.expression)
            case "appliesContentType":
                appliesContentType = HTTPMediaType.parse(memberName: argument.expression.memberAccess!.declName.baseName.text)
            case "appliesHeaders":
                appliesHeaders = HTTPRequestHeader.parse(context: context, argument.expression)
            case "appliesCookies":
                appliesCookies = argument.expression.array!.elements.compactMap({ Cookie.parse(context: context, expr: $0.expression) })
            case "excludedRoutes":
                excludedRoutes = Set(argument.expression.array!.elements.compactMap({ $0.expression.stringLiteral?.string }))
            default:
                break
            }
        }
        return StaticMiddleware(
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