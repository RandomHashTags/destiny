//
//  StaticMiddleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes
import SwiftSyntax

// MARK: StaticMiddleware
/// The default Static Middleware that powers Destiny's static middleware which handles static & dynamic routes at compile time.
public struct StaticMiddleware : StaticMiddlewareProtocol {
    public let appliesToMethods:Set<HTTPRequest.Method>
    public let appliesToStatuses:Set<HTTPResponse.Status>
    public let appliesToContentTypes:Set<HTTPField.ContentType>

    public let appliesStatus:HTTPResponse.Status?
    public let appliesHeaders:[String:String]

    public init(
        appliesToMethods: Set<HTTPRequest.Method> = [],
        appliesToStatuses: Set<HTTPResponse.Status> = [],
        appliesToContentTypes: Set<HTTPField.ContentType> = [],
        appliesStatus: HTTPResponse.Status? = nil,
        appliesHeaders: [String:String] = [:]
    ) {
        self.appliesToMethods = appliesToMethods
        self.appliesToStatuses = appliesToStatuses
        self.appliesToContentTypes = appliesToContentTypes
        self.appliesStatus = appliesStatus
        self.appliesHeaders = appliesHeaders
    }
}

public extension StaticMiddleware {
    static func parse(_ function: FunctionCallExprSyntax) -> Self {
        var appliesToMethods:Set<HTTPRequest.Method> = []
        var appliesToStatuses:Set<HTTPResponse.Status> = []
        var appliesToContentTypes:Set<HTTPField.ContentType> = []
        var appliesStatus:HTTPResponse.Status? = nil
        var appliesHeaders:[String:String] = [:]
        for argument in function.arguments {
            switch argument.label!.text {
                case "appliesToMethods":
                    appliesToMethods = Set(argument.expression.array!.elements.map({ HTTPRequest.Method(rawValue: "\($0.expression.memberAccess!.declName.baseName.text)".uppercased())! }))
                    break
                case "appliesToStatuses":
                    appliesToStatuses = Set(argument.expression.array!.elements.map({ HTTPResponse.Status.parse($0.expression.memberAccess!.declName.baseName.text) }))
                    break
                case "appliesToContentTypes":
                    appliesToContentTypes = Set(argument.expression.array!.elements.map({ HTTPField.ContentType(rawValue: "\($0.expression.memberAccess!.declName.baseName.text)") }))
                    break
                case "appliesStatus":
                    appliesStatus = HTTPResponse.Status.parse(argument.expression.memberAccess!.declName.baseName.text)
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
            appliesToMethods: appliesToMethods,
            appliesToStatuses: appliesToStatuses,
            appliesToContentTypes: appliesToContentTypes,
            appliesStatus: appliesStatus,
            appliesHeaders: appliesHeaders
        )
    }
}