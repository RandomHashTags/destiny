//
//  HTTPStartLine.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

import HTTPTypes

public struct HTTPStartLine {
    public let method:HTTPRequest.Method
    public let path:[String]
    public let version:String

    public init(
        method: HTTPRequest.Method,
        path: [String],
        version: String
    ) {
        self.method = method
        self.path = path
        self.version = version
    }
}