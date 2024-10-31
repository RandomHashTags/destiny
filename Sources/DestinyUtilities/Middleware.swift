//
//  Middleware.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes
import SwiftSyntax

// MARK: MiddlewareProtocol
/// The core Middleware protocol that powers Destiny's Middleware.
public protocol MiddlewareProtocol : Sendable {
    static func parse(_ function: FunctionCallExprSyntax) -> Self
}

// MARK: DynamicMiddlewareProtocol
/// A `MiddlewareProtocol` that handles requests dynamically.
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol, CustomStringConvertible {
    /// Whether or not this middleware handles a request asynchronously or synchronously.
    var isAsync : Bool { get }
    
    /// Whether or not this middleware should handle a request.
    func shouldHandle(request: borrowing Request) -> Bool

    func handle(request: borrowing Request, response: inout DynamicResponse) throws
    func handleAsync(request: borrowing Request, response: inout DynamicResponse) async throws
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
/// A `MiddlewareProtocol` that handles routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    var appliesToMethods : Set<HTTPRequest.Method> { get }
    var appliesToStatuses : Set<HTTPResponse.Status> { get }
    var appliesToContentTypes : Set<HTTPField.ContentType> { get }

    var appliesStatus : HTTPResponse.Status? { get }
    var appliesHeaders : [String:String] { get }
}