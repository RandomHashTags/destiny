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
    public let handlesVersions:Set<HTTPVersion>?
    public let handlesMethods:Set<HTTPRequestMethod>?
    public let handlesStatuses:Set<HTTPResponseStatus>?
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponseStatus?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:[String:String]

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: Set<HTTPRequestMethod>? = nil,
        handlesStatuses: Set<HTTPResponseStatus>? = nil,
        handlesContentTypes: [any HTTPMediaTypeProtocol]? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: [String:String] = [:]
    ) {
        self.handlesVersions = handlesVersions
        self.handlesMethods = handlesMethods
        self.handlesStatuses = handlesStatuses
        if let handlesContentTypes:[any HTTPMediaTypeProtocol] = handlesContentTypes {
            self.handlesContentTypes = Set(handlesContentTypes.map({ $0.structure }))
        } else {
            self.handlesContentTypes = nil
        }
        self.appliesVersion = appliesVersion
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
    }

    public var debugDescription : String {
        var values:[String] = []
        if let versions:Set<HTTPVersion> = handlesVersions {
            values.append("handlesVersions: [" + versions.map({ ".\($0)" }).joined(separator: ",") + "]")
        }
        if let methods:Set<HTTPRequestMethod> = handlesMethods {
            values.append("handlesMethods: [" + methods.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let statuses:Set<HTTPResponseStatus> = handlesStatuses {
            values.append("handlesStatuses: [" + statuses.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let contentTypes:Set<HTTPMediaType> = handlesContentTypes {
            values.append("handlesContentTypes: [" + contentTypes.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let appliesVersion:HTTPVersion = appliesVersion {
            values.append("appliesVersion: .\(appliesVersion)")
        }
        if let appliesStatus:HTTPResponseStatus = appliesStatus {
            values.append("appliesStatus: \(appliesStatus.debugDescription)")
        }
        if let appliesContentType:HTTPMediaType = appliesContentType {
            values.append("appliesStatus: \(appliesContentType.debugDescription)")
        }
        if !appliesHeaders.isEmpty {
            values.append("appliesHeaders: \(appliesHeaders)")
        }
        return "StaticMiddleware(" + values.joined(separator: ",") + ")"
    }
}

// MARK: Parse
extension StaticMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:Set<HTTPRequestMethod>? = nil
        var handlesStatuses:Set<HTTPResponseStatus>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponseStatus? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:[String:String] = [:]
        for argument in function.arguments {
            switch argument.label!.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequestMethod(expr: $0.expression) }))
            case "handlesStatuses":
                handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponseStatus(expr: $0.expression) }))
            case "handlesContentTypes":
                handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaTypes.parse("\($0.expression.memberAccess!.declName.baseName.text)") }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(argument.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponseStatus(expr: argument.expression)
            case "appliesContentType":
                appliesContentType = HTTPMediaTypes.parse(argument.expression.memberAccess!.declName.baseName.text)
            case "appliesHeaders":
                appliesHeaders = HTTPRequestHeader.parse(context: context, argument.expression)
            default:
                break
            }
        }
        return StaticMiddleware(
            handlesVersions: handlesVersions,
            handlesMethods: handlesMethods,
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes != nil ? Array(handlesContentTypes!) : nil,
            appliesVersion: appliesVersion,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: appliesHeaders
        )
    }
}