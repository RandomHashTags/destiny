//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

// MARK: RouterGroup
public struct RouterGroup : Sendable {
    public let method:HTTPRequest.Method?
    public let path:String
    public let routers:[Router]

    public init(
        method: HTTPRequest.Method? = nil,
        path: String,
        routers: [Router]
    ) {
        self.method = method
        self.path = path
        self.routers = routers
    }
}

// MARK: Router
public struct Router : Sendable {
    public let staticResponses:[StackString32:RouteResponseProtocol]

    public init(staticResponses: [StackString32:RouteResponseProtocol]) {
        self.staticResponses = staticResponses
    }
}

public enum RouterReturnType : String {
    case staticString, uint8Array, uint16Array
    case data
    case unsafeBufferPointer
}

// MARK: Middleware
public protocol MiddlewareProtocol : Hashable {
    var appliesToMethods : Set<HTTPRequest.Method> { get }
    var appliesToStatuses : Set<HTTPResponse.Status> { get }
    var appliesToContentTypes : Set<HTTPField.ContentType> { get }

    var appliesStatus : HTTPResponse.Status? { get }
    var appliesHeaders : [String:String] { get }
}
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
}
public struct StaticMiddleware : MiddlewareProtocol {
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

// MARK: RouteProtocol
public protocol RouteProtocol {
    static var routeType : RouteType { get }
    var result : RouteResult { get }
}

public enum RouteType {
    case `static`, dynamic
}

// MARK: RouteResult
public enum RouteResult {
    case string(String)
    case bytes([UInt8])

    var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
        }
    }
}

// MARK: StaticRoute
public struct StaticRoute : RouteProtocol {
    public static let routeType:RouteType = .static
    
    public let method:HTTPRequest.Method
    public package(set) var path:String
    public let status:HTTPResponse.Status?
    public let contentType:HTTPField.ContentType, charset:String?
    public let result:RouteResult

    public init(
        method: HTTPRequest.Method,
        path: String,
        status: HTTPResponse.Status? = nil,
        contentType: HTTPField.ContentType,
        charset: String? = nil,
        result: RouteResult
    ) {
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.result = result
    }

    package func response(version: String, middleware: [any MiddlewareProtocol]) -> String {
        var response_status:HTTPResponse.Status? = status
        var headers:[String:String] = [:]
        headers[HTTPField.Name.contentType.rawName] = contentType.rawValue + (charset != nil ? "; charset=" + charset! : "")
        for middleware in middleware {
            if middleware.appliesToMethods.contains(method) && middleware.appliesToContentTypes.contains(contentType)
                    && (response_status != nil ? middleware.appliesToStatuses.contains(response_status!) : true) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applied_status
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        let result_string:String
        switch result {
            case .string(let string):
                result_string = string
                break
            case .bytes(let bytes):
                result_string = bytes.map({ "\($0)" }).joined()
                break
        }
        var string:String = version + " \(response_status ?? HTTPResponse.Status.notImplemented)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        // TODO: fix ERR_CONTENT_LENGTH_MISMATCH 200 (OK) | calculation is somehow incorrect for json & html
        string += HTTPField.Name.contentLength.rawName + ": \(result.count)"
        return string + "\\r\\n\\r\\n" + result_string
    }
}

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:StackString64
    public let headers:[HTTPField.Name:String]
}