//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import HTTPTypes

public struct DynamicResponse : DynamicResponseProtocol {
    public var status:HTTPResponse.Status
    public var headers:[String:String]
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
    public func response(version: String) throws -> String {
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