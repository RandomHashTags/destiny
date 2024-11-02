//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import HTTPTypes

public struct DynamicResponse : Sendable, CustomDebugStringConvertible {
    /// The response status.
    public var status:HTTPResponse.Status
    /// The response headers.
    public var headers:[String:String]
    /// The response content.
    public var result:RouteResult

    public init(
        status: HTTPResponse.Status,
        headers: [String:String],
        result: RouteResult
    ) {
        self.status = status
        self.headers = headers
        self.result = result
    }

    @inlinable
    package func response(version: String) throws -> String {
        let result_string:String = try result.string()
        var string:String = version + " \(status)\r\n"
        for (header, value) in headers {
            string += header + ": " + value + "\r\n"
        }
        string += HTTPField.Name.contentLength.rawName + ": \(result_string.count)"
        return string + "\r\n\r\n" + result_string
    }

    public var debugDescription : String {
        return "DynamicResponse(status: .\(status.caseName!), headers: \(headers), result: .\(result))"
    }
}