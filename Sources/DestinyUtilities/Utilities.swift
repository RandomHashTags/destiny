//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

public typealias DestinyRoutePathType = StackString32

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
    public let staticResponses:[DestinyRoutePathType:StaticRouteResponseProtocol]
    public let dynamicResponses:[DestinyRoutePathType:DynamicRouteResponseProtocol]
    public let dynamicMiddleware:[DynamicMiddlewareProtocol]
    
    public init(
        staticResponses: [DestinyRoutePathType:StaticRouteResponseProtocol],
        dynamicResponses: [DestinyRoutePathType:DynamicRouteResponseProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol]
    ) {
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.dynamicResponses = dynamicResponses
    }
}

public struct RouterReturnType {
    public static func bytes<T: FixedWidthInteger>(_ bytes: [T]) -> String {
        return "[" + bytes.map({ "\($0)" }).joined(separator: ",") + "]"
    }
    private static func response(valueType: String, _ string: String) -> String {
        return "RouteResponses." + valueType + "(" + string + ")"
    }
    
    public static let staticString:RouterReturnType = RouterReturnType(
        rawValue: "staticString",
        encode: { response(valueType: "StaticString", "\"" + $0 + "\"") }
    )
    public static let uint8Array:RouterReturnType = RouterReturnType(
        rawValue: "uint8Array",
        encode: { response(valueType: "UInt8Array", bytes([UInt8]($0.utf8))) }
    )
    public static let uint16Array:RouterReturnType = RouterReturnType(
        rawValue: "uint16Array",
        encode: { response(valueType: "UInt16Array", bytes([UInt16]($0.utf16))) }
    )
    public static let data:RouterReturnType = RouterReturnType(
        rawValue: "data",
        encode: { response(valueType: "Data", bytes([UInt8]($0.utf8))) }
    )
    public static let unsafeBufferPointer:RouterReturnType = RouterReturnType(
        rawValue: "unsafeBufferPointer",
        encode: { response(valueType: "UnsafeBufferPointer", "StaticString(\"" + $0 + "\").withUTF8Buffer { $0 }") }
    )

    public static var custom:[String:RouterReturnType] = [:]
    
    public let rawValue:String
    public let encode:(String) -> String

    public init(rawValue: String, encode: @escaping (String) -> String) {
        self.rawValue = rawValue
        self.encode = encode
    }
    public init?(rawValue: String) {
        switch rawValue {
            case "staticString":        self = .staticString
            case "uint8Array":          self = .uint8Array
            case "uint16Array":         self = .uint16Array
            case "data":                self = .data
            case "unsafeBufferPointer": self = .unsafeBufferPointer
            default:
                guard let target:RouterReturnType = Self.custom[rawValue] else { return nil }
                self = target
        }
    }
}

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:[String]
    public let version:String
    public let headers:[String:String]
    public let body:String

    public init(
        method: HTTPRequest.Method,
        path: [String],
        version: String,
        headers: [String:String],
        body: String
    ) {
        self.method = method
        self.path = path
        self.version = version
        self.headers = headers
        self.body = body
    }
}