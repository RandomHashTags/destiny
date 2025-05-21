
import DestinyBlueprint
import OrderedCollections
import SwiftSyntax
import SwiftSyntaxMacros

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
    public let handlesMethods:Set<HTTPRequestMethod>?

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

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: Set<HTTPRequestMethod>? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus.Code? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: OrderedDictionary<String, String> = [:],
        appliesCookies: [Cookie] = []
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
    }

    public var debugDescription: String {
        var values = [String]()
        if let handlesVersions {
            values.append("handlesVersions: [" + handlesVersions.map({ ".\($0)" }).joined(separator: ",") + "]")
        }
        if let handlesMethods {
            values.append("handlesMethods: [" + handlesMethods.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let handlesStatuses {
            values.append("handlesStatuses: \(handlesStatuses)")
        }
        if let handlesContentTypes {
            values.append("handlesContentTypes: [" + handlesContentTypes.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let appliesVersion {
            values.append("appliesVersion: .\(appliesVersion)")
        }
        if let appliesStatus {
            values.append("appliesStatus: \(appliesStatus)")
        }
        if let appliesContentType {
            values.append("appliesStatus: \(appliesContentType.debugDescription)")
        }
        if !appliesHeaders.isEmpty {
            values.append("appliesHeaders: \(appliesHeaders)")
        }
        if !appliesCookies.isEmpty {
            values.append("appliesCookies: [" + appliesCookies.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        return "StaticMiddleware(" + values.joined(separator: ",") + ")"
    }
}

extension StaticMiddleware {
    @inlinable
    public func handlesVersion(_ version: HTTPVersion) -> Bool {
        handlesVersions?.contains(version) ?? true
    }

    @inlinable
    public func handlesMethod(_ method: HTTPRequestMethod) -> Bool {
        handlesMethods?.contains(method) ?? true
    }

    @inlinable
    public func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool {
        handlesStatuses?.contains(code) ?? true
    }

    @inlinable
    public func handlesContentType(_ mediaType: HTTPMediaType) -> Bool {
        handlesContentTypes?.contains(mediaType) ?? true
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:Set<HTTPRequestMethod>? = nil
        var handlesStatuses:Set<HTTPResponseStatus.Code>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus.Code? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:OrderedDictionary<String, String> = [:]
        var appliesCookies:[Cookie] = []
        for argument in function.arguments {
            switch argument.label?.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequestMethod(expr: $0.expression) }))
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
            appliesCookies: appliesCookies
        )
    }
}
#endif