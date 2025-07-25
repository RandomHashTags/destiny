
import DestinyBlueprint
import OrderedCollections

// MARK: StaticMiddleware
/// Default Static Middleware implementation which handles static & dynamic routes at compile time.
public struct StaticMiddleware: StaticMiddlewareProtocol {
    public typealias Cookie = HTTPCookie

    /// Route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    public let handlesVersions:Set<HTTPVersion>?

    /// Route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    public let handlesMethods:[any HTTPRequestMethodProtocol]?

    /// Route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    public let handlesStatuses:Set<HTTPResponseStatus.Code>?

    /// The route content types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponseStatus.Code?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:OrderedDictionary<String, String>
    public let appliesCookies:[Cookie]
    public let excludedRoutes:Set<String>

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus.Code? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: OrderedDictionary<String, String> = [:],
        appliesCookies: [Cookie] = [],
        excludedRoutes: Set<String> = []
    ) {
        self.handlesVersions = handlesVersions
        self.handlesMethods = handlesMethods
        self.handlesStatuses = handlesStatuses
        self.handlesContentTypes = handlesContentTypes
        self.appliesVersion = appliesVersion
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
        self.appliesCookies = appliesCookies
        self.excludedRoutes = excludedRoutes
    }

    @inlinable
    public func handles<Method: HTTPRequestMethodProtocol>(
        version: HTTPVersion,
        path: String,
        method: Method,
        contentType: HTTPMediaType?,
        status: HTTPResponseStatus.Code
    ) -> Bool {
        return !excludedRoutes.contains(path)
            && handlesVersion(version)
            && handlesMethod(method)
            && handlesContentType(contentType)
            && handlesStatus(status)
    }
}

extension StaticMiddleware {
    @inlinable
    public func handlesVersion(_ version: HTTPVersion) -> Bool {
        handlesVersions?.contains(version) ?? true
    }

    @inlinable
    public func handlesMethod<Method: HTTPRequestMethodProtocol>(_ method: Method) -> Bool {
        guard let handlesMethods else { return true }
        let rn = method.rawNameString()
        for m in handlesMethods {
            if m.rawNameString() == rn {
                return true
            }
        }
        return false
    }

    @inlinable
    public func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool {
        handlesStatuses?.contains(code) ?? true
    }

    @inlinable
    public func handlesContentType(_ mediaType: HTTPMediaType?) -> Bool {
        if let mediaType {
            handlesContentTypes?.contains(mediaType) ?? true
        } else {
            true
        }
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension StaticMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:[any HTTPRequestMethodProtocol]? = nil
        var handlesStatuses:Set<HTTPResponseStatus.Code>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus.Code? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:OrderedDictionary<String, String> = [:]
        var appliesCookies:[Cookie] = []
        var excludedRoutes:Set<String> = []
        for argument in function.arguments {
            switch argument.label?.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = argument.expression.array?.elements.compactMap({ HTTPRequestMethod.parse(expr: $0.expression) })
            case "handlesStatuses":
                handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponseStatus.parse(expr: $0.expression)?.code }))
            case "handlesContentTypes":
                handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaType.parse(memberName: "\($0.expression.memberAccess!.declName.baseName.text)") }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(argument.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus.parse(expr: argument.expression)?.code
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
#endif