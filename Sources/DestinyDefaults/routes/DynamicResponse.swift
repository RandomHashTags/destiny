//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

#if canImport(DestinyUtilities)
import DestinyUtilities
#endif

public struct DynamicResponse : DynamicResponseProtocol {
    public var headers:[String:String]
    public var result:RouteResult
    public var parameters:[String]
    public var version:HTTPVersion
    public var status:HTTPResponseStatus

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: [String:String],
        result: RouteResult,
        parameters: [String]
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.result = result
        self.parameters = parameters
    }

    @inlinable
    public func response() throws -> String {
        let result:String = try result.string()
        var string:String = version.string() + " \(status)\r\n"
        for (header, value) in headers {
            string += header + ": " + value + "\r\n"
        }
        return string + HTTPResponseHeader.contentLength.rawName + ": \(result.utf8.count)\r\n\r\n" + result
    }

    public var debugDescription : String {
        return "DynamicResponse(version: .\(version), status: \(status.debugDescription), headers: \(headers), result: \(result.debugDescription), parameters: \(parameters))"
    }
}