//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import HTTPTypes

public struct DynamicResponse : DynamicResponseProtocol {
    public var version:String
    public var status:HTTPResponse.Status
    public var headers:[String:String]
    public var result:RouteResult
    public var parameters:[String:String]

    public init(
        version: String,
        status: HTTPResponse.Status,
        headers: [String:String],
        result: RouteResult,
        parameters: [String:String]
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.result = result
        self.parameters = parameters
    }

    @inlinable
    public func response() throws -> String {
        let result_string:String = try result.string()
        var string:String = version + " \(status)\r\n"
        for (header, value) in headers {
            string += header + ": " + value + "\r\n"
        }
        string += HTTPField.Name.contentLength.rawName + ": \(result_string.count)"
        return string + "\r\n\r\n" + result_string
    }

    public var debugDescription : String {
        return "DynamicResponse(version: \"\(version)\", status: .\(status.caseName!), headers: \(headers), result: .\(result), parameters: \(parameters))"
    }
}