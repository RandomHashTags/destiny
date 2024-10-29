//
//  Middleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes
import SwiftSyntax

// MARK: MiddlewareProtocol
public protocol MiddlewareProtocol {
    var middlewareType : MiddlewareType { get }
    var appliesToMethods : Set<HTTPRequest.Method> { get }
    var appliesToStatuses : Set<HTTPResponse.Status> { get }
    var appliesToContentTypes : Set<HTTPField.ContentType> { get }

    var appliesStatus : HTTPResponse.Status? { get }
    var appliesHeaders : [String:String] { get }

    static func parse(_ syntax: FunctionCallExprSyntax) -> Self
}

public enum MiddlewareType {
    case `static`, dynamic
}

// MARK: DynamicMiddlewareProtocol
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
}
public extension DynamicMiddlewareProtocol {
    var middlewareType : MiddlewareType { .dynamic }
}

/*
// MARK: DynamicMiddleware
public struct DynamicMiddleware : DynamicMiddlewareProtocol {
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
}*/

// MARK: StaticMiddlewareProtocol
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
}
public extension StaticMiddlewareProtocol {
    var middlewareType : MiddlewareType { .static }
}