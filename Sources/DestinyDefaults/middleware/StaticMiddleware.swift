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
    public let handlesMethods:Set<HTTPRequest.Method>?
    public let handlesStatuses:Set<HTTPResponse.Status>?
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesStatus:HTTPResponse.Status?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:[String:String]

    public init(
        handlesMethods: Set<HTTPRequest.Method>? = nil,
        handlesStatuses: Set<HTTPResponse.Status>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesStatus: HTTPResponse.Status? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: [String:String] = [:]
    ) {
        self.handlesMethods = handlesMethods
        self.handlesStatuses = handlesStatuses
        self.handlesContentTypes = handlesContentTypes
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
    }

    public var debugDescription : String {
        let handles_methods:String = handlesMethods != nil ? "[" + handlesMethods!.map({ "." + $0.caseName! }).joined(separator: ",") + "]" : "nil"
        let handles_statuses:String = handlesStatuses != nil ? "[" + handlesStatuses!.map({ "." + $0.caseName! }).joined(separator: ",") + "]" : "nil"
        let handles_content_types:String = handlesContentTypes != nil ? "[" + handlesContentTypes!.map({ $0.debugDescription }).joined(separator: ",") + "]" : "nil"
        let applies_content_type:String = appliesContentType != nil ? "." + appliesContentType!.caseName : "nil"
        let applies_status:String = appliesStatus != nil ? "." + appliesStatus!.caseName! : "nil"
        return "StaticMiddleware(handlesMethods: \(handles_methods), handlesStatuses: \(handles_statuses), handlesContentTypes: \(handles_content_types), appliesStatus: \(applies_status), appliesContentType: \(applies_content_type), appliesHeaders: \(appliesHeaders))"
    }
}

public extension StaticMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> Self {
        var handlesMethods:Set<HTTPRequest.Method>? = nil
        var handlesStatuses:Set<HTTPResponse.Status>? = nil
        var handlesContentTypes:Set<HTTPMediaType>? = nil
        var appliesStatus:HTTPResponse.Status? = nil
        var appliesContentType:HTTPMediaType? = nil
        var appliesHeaders:[String:String] = [:]
        for argument in function.arguments {
            switch argument.label!.text {
                case "handlesMethods":
                    handlesMethods = Set(argument.expression.array!.elements.map({ HTTPRequest.Method(rawValue: "\($0.expression.memberAccess!.declName.baseName.text)".uppercased())! }))
                    break
                case "handlesStatuses":
                    handlesStatuses = Set(argument.expression.array!.elements.compactMap({ HTTPResponse.Status.parse($0.expression.memberAccess!.declName.baseName.text) }))
                    break
                case "handlesContentTypes":
                    handlesContentTypes = Set(argument.expression.array!.elements.compactMap({ HTTPMediaType.parse("\($0.expression.memberAccess!.declName.baseName.text)") }))
                    break
                case "appliesStatus":
                    appliesStatus = HTTPResponse.Status.parse(argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "appliesContentType":
                    appliesContentType = HTTPMediaType.parse(argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "appliesHeaders":
                    let dictionary:[(String, String)] = argument.expression.dictionary!.content.as(DictionaryElementListSyntax.self)!.map({ ($0.key.stringLiteral!.string, $0.value.stringLiteral!.string) })
                    for (key, value) in dictionary {
                        appliesHeaders[key] = value
                    }
                    break
                default:
                    break
            }
        }
        return StaticMiddleware(
            handlesMethods: handlesMethods,
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: appliesHeaders
        )
    }
}