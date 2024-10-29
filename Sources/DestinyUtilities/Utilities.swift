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

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:StackString32
    public let version:String
    public let headers:[HTTPField.Name:String]
}