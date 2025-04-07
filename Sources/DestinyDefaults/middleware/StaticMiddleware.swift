//
//  StaticMiddleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticMiddleware
/// Default Static Middleware implementation which handles static & dynamic routes at compile time.
public struct StaticMiddleware : StaticMiddlewareProtocol {

    public typealias ConcreteHTTPCookie = HTTPCookie
    public typealias ConcreteHTTPRequestMethod = HTTPRequestMethod
    public typealias ConcreteHTTPResponseHeaders = HTTPResponseHeaders

    public let handlesVersions:Set<HTTPVersion>?
    public let handlesMethods:Set<ConcreteHTTPRequestMethod>?
    public let handlesStatuses:Set<HTTPResponseStatus>?
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponseStatus?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:ConcreteHTTPResponseHeaders
    public let appliesCookies:[ConcreteHTTPCookie]

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: Set<ConcreteHTTPRequestMethod>? = nil,
        handlesStatuses: Set<HTTPResponseStatus>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: [String:String] = [:],
        appliesCookies: [ConcreteHTTPCookie] = []
    ) {
        self.init(
            handlesVersions: handlesVersions,
            handlesMethods: handlesMethods,
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes,
            appliesVersion: appliesVersion,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: .init(custom: appliesHeaders),
            appliesCookies: appliesCookies
        )
    }
    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: Set<ConcreteHTTPRequestMethod>? = nil,
        handlesStatuses: Set<HTTPResponseStatus>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: ConcreteHTTPResponseHeaders,
        appliesCookies: [ConcreteHTTPCookie] = []
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

    public var debugDescription : String {
        var values:[String] = []
        if let handlesVersions {
            values.append("handlesVersions: [" + handlesVersions.map({ ".\($0)" }).joined(separator: ",") + "]")
        }
        if let handlesMethods {
            values.append("handlesMethods: [" + handlesMethods.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let handlesStatuses {
            values.append("handlesStatuses: [" + handlesStatuses.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let handlesContentTypes {
            values.append("handlesContentTypes: [" + handlesContentTypes.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let appliesVersion {
            values.append("appliesVersion: .\(appliesVersion)")
        }
        if let appliesStatus {
            values.append("appliesStatus: \(appliesStatus.debugDescription)")
        }
        if let appliesContentType {
            values.append("appliesStatus: \(appliesContentType.debugDescription)")
        }
        values.append("appliesHeaders: \(appliesHeaders.debugDescription)")
        if !appliesCookies.isEmpty {
            values.append("appliesCookies: [" + appliesCookies.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        return "StaticMiddleware(" + values.joined(separator: ",") + ")"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:Set<HTTPRequestMethod>? = nil
        var handlesStatuses:Set<HTTPResponseStatus>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:ConcreteHTTPResponseHeaders = .init()
        var appliesCookies:[ConcreteHTTPCookie] = []
        for argument in function.arguments {
            switch argument.label?.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequestMethod(expr: $0.expression) }))
            case "handlesStatuses":
                handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponseStatus(expr: $0.expression) }))
            case "handlesContentTypes":
                handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaType.parse(context: context, expr: $0.expression) }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(argument.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus(expr: argument.expression)
            case "appliesContentType":
                appliesContentType = HTTPMediaType.parse(context: context, expr: argument.expression)
            case "appliesHeaders":
                let custom:[String:String] = HTTPRequestHeader.parse(context: context, argument.expression)
                appliesHeaders = .init(custom: custom)
            case "appliesCookies":
                appliesCookies = argument.expression.array!.elements.compactMap({ HTTPCookie.parse(context: context, expr: $0.expression) })
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