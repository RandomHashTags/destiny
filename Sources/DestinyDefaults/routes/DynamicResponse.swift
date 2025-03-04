//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities

public struct DynamicResponse : DynamicResponseProtocol {
    public typealias ConcreteHTTPResponseHeaders = HTTPResponseHeaders
    public typealias ConcreteHTTPCookie = HTTPCookie

    public var timestamps:DynamicRequestTimestamps
    public var headers:ConcreteHTTPResponseHeaders
    public var cookies:[ConcreteHTTPCookie]
    public var result:RouteResult
    public var parameters:[String]
    public var version:HTTPVersion
    public var status:HTTPResponseStatus

    public init(
        timestamps: DynamicRequestTimestamps = DynamicRequestTimestamps(received: .now, loaded: .now, processed: .now),
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: ConcreteHTTPResponseHeaders,
        cookies: [ConcreteHTTPCookie],
        result: RouteResult,
        parameters: [String]
    ) {
        self.timestamps = timestamps
        self.version = version
        self.status = status
        self.headers = headers
        self.cookies = cookies
        self.result = result
        self.parameters = parameters
    }

    @inlinable
    public func response() throws -> String {
        let result:String = try result.string()
        var string:String = version.string + " \(status)\r\n"
        headers.iterate { header, value in
            string += header + ": " + value + "\r\n"
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)\r\n"
        }
        return string + HTTPResponseHeader.contentLength.rawName + ": \(result.utf8.count)\r\n\r\n" + result
    }

    public var debugDescription : String {
        return "DynamicResponse(version: .\(version), status: \(status.debugDescription), headers: \(headers.debugDescription), cookies: ["
            + cookies.map({ $0.debugDescription }).joined(separator: ",")
            + "], result: \(result.debugDescription), parameters: \(parameters))"
    }
}