//
//  StaticMiddleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax

// MARK: StaticMiddleware
/// The default Static Middleware that powers Destiny's static middleware which handles static & dynamic routes at compile time.
public struct StaticMiddleware : StaticMiddlewareProtocol {
    public let handlesVersions:Set<HTTPVersion>?
    public let handlesMethods:Set<HTTPRequest.Method>?
    public let handlesStatuses:Set<HTTPResponse.Status>?
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponse.Status?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:[String:String]

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: Set<HTTPRequest.Method>? = nil,
        handlesStatuses: Set<HTTPResponse.Status>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponse.Status? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: [String:String] = [:]
    ) {
        self.handlesVersions = handlesVersions
        self.handlesMethods = handlesMethods
        self.handlesStatuses = handlesStatuses
        self.handlesContentTypes = handlesContentTypes
        self.appliesVersion = appliesVersion
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
    }

    public var debugDescription : String {
        var values:[String] = []
        if let versions:Set<HTTPVersion> = handlesVersions {
            values.append("handlesVersions: [" + versions.map({ "\($0)" }).joined(separator: ",") + "]")
        }
        if let methods:Set<HTTPRequest.Method> = handlesMethods {
            values.append("handlesMethods: [" + methods.map({ "." + $0.caseName! }).joined(separator: ",") + "]")
        }
        if let statuses:Set<HTTPResponse.Status> = handlesStatuses {
            values.append("handlesStatuses: [" + statuses.map({ "." + $0.caseName! }).joined(separator: ",") + "]")
        }
        if let contentTypes:Set<HTTPMediaType> = handlesContentTypes {
            values.append("handlesContentTypes: [" + contentTypes.map({ $0.debugDescription }).joined(separator: ",") + "]")
        }
        if let appliesVersion:HTTPVersion = appliesVersion {
            values.append("appliesVersion: \(appliesVersion)")
        }
        if let appliesStatus:HTTPResponse.Status = appliesStatus {
            values.append("appliesStatus: ." + appliesStatus.caseName!)
        }
        if let appliesContentType:HTTPMediaType = appliesContentType {
            values.append("appliesStatus: ." + appliesContentType.caseName)
        }
        if !appliesHeaders.isEmpty {
            values.append("appliesHeaders: \(appliesHeaders)")
        }
        return "StaticMiddleware(" + values.joined(separator: ",") + ")"
    }
}

public extension StaticMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> Self {
        var handlesVersions:Set<HTTPVersion>? = nil
        var handlesMethods:Set<HTTPRequest.Method>? = nil
        var handlesStatuses:Set<HTTPResponse.Status>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesVersion:HTTPVersion? = nil
        var appliesStatus:HTTPResponse.Status? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:[String:String] = [:]
        for argument in function.arguments {
            switch argument.label!.text {
            case "handlesVersions":
                handlesVersions = Set(argument.expression.array!.elements.compactMap({ HTTPVersion.parse($0.expression) }))
            case "handlesMethods":
                handlesMethods = Set(argument.expression.array!.elements.compactMap({ HTTPRequest.Method(expr: $0.expression) }))
            case "handlesStatuses":
                handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponse.Status(expr: $0.expression) }))
            case "handlesContentTypes":
                handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaType.parse("\($0.expression.memberAccess!.declName.baseName.text)") }))
            case "appliesVersion":
                appliesVersion = HTTPVersion.parse(argument.expression)
            case "appliesStatus":
                appliesStatus = HTTPResponse.Status.parse(argument.expression.memberAccess!.declName.baseName.text)
            case "appliesContentType":
                appliesContentType = HTTPMediaType.parse(argument.expression.memberAccess!.declName.baseName.text)
            case "appliesHeaders":
                let dictionary:[(String, String)] = argument.expression.dictionary!.content.as(DictionaryElementListSyntax.self)!.map({ ($0.key.stringLiteral!.string, $0.value.stringLiteral!.string) })
                for (key, value) in dictionary {
                    appliesHeaders[key] = value
                }
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
            appliesHeaders: appliesHeaders
        )
    }
}