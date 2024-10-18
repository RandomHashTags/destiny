//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import HTTPTypes
import NIOCore

// MARK: Router
public struct Router : Sendable {
    public private(set) var staticResponses:[Substring:RouteResponseProtocol]

    public init(staticResponses: [Substring:RouteResponseProtocol]) {
        self.staticResponses = staticResponses
    }
}

public enum RouterReturnType : String {
    case staticString, uint8Array, uint16Array, byteBuffer
    #if canImport(Foundation)
    case data
    #endif
}

// MARK: Middleware
public struct Middleware : Hashable {
    public let appliesToMethods:Set<HTTPRequest.Method>
    public let appliesToContentTypes:Set<Route.ContentType>

    public let appliesHeaders:[String:String]

    public init(appliesToMethods: Set<HTTPRequest.Method> = [], appliesToContentTypes: Set<Route.ContentType> = [], appliesHeaders: [String:String] = [:]) {
        self.appliesToMethods = appliesToMethods
        self.appliesToContentTypes = appliesToContentTypes
        self.appliesHeaders = appliesHeaders
    }
}

// MARK: Route
public struct Route {
    public let method:HTTPRequest.Method
    public package(set) var path:String
    public let status:HTTPResponse.Status
    public let contentType:ContentType, charset:String
    public let staticResult:Result?
    public let dynamicResult:((borrowing Request?) -> Result)?

    public init(
        method: HTTPRequest.Method,
        path: String,
        status: HTTPResponse.Status = .ok,
        contentType: ContentType,
        charset: String,
        staticResult: Result?,
        dynamicResult: ((borrowing Request?) -> Result)?
    ) {
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.staticResult = staticResult
        self.dynamicResult = dynamicResult
    }

    public enum ContentType : String {
        case text, html, json

        var htmlValue : String {
            switch self {
                case .text: return "text/plain"
                case .html: return "text/html"
                case .json: return "application/json"
            }
        }
    }

    package func response(version: String, middleware: [Middleware]) -> String {
        let middleware:[Middleware] = middleware.filter({ $0.appliesToMethods.contains(method) && $0.appliesToContentTypes.contains(contentType) })
        let result:Result = staticResult ?? dynamicResult!(nil), result_string:String
        switch result {
            case .string(let string):
                result_string = string
                break
            case .bytes(let bytes):
                result_string = bytes.map({ "\($0)" }).joined()
                break
        }
        var string:String = version + " \(status)\\r\\n"

        var headers:[String:String] = [:]
        headers[HTTPField.Name.contentType.rawName] = contentType.htmlValue + "; charset=" + charset
        for m in middleware {
            for (header, value) in m.appliesHeaders {
                headers[header] = value
            }
        }
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        string += HTTPField.Name.contentLength.rawName + ": \(result.count)"
        return string + "\\r\\n\\r\\n" + result_string
    }

    public enum Result {
        case string(String)
        case bytes([UInt8])

        var count : Int {
            switch self {
                case .string(let string): return string.utf8.count
                case .bytes(let bytes): return bytes.count
            }
        }
    }
}

public struct Request : ~Copyable {
    public let headers:[HTTPField.Name:String]
}