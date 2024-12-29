//
//  CompleteHTTPResponse.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import Foundation
import HTTPTypes

/// The default storage for a complete HTTP response.
public struct CompleteHTTPResponse : Sendable {
    public var version:HTTPVersion
    public var status:HTTPResponse.Status
    public var headers:[String:String]
    public var result:RouteResult?
    public var contentType:HTTPMediaType?
    public var charset:String?

    public init(
        version: HTTPVersion,
        status: HTTPResponse.Status,
        headers: [String:String],
        result: RouteResult?,
        contentType: HTTPMediaType?,
        charset: String?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.result = result
        self.contentType = contentType
        self.charset = charset
    }
    

    @inlinable
    public func string() throws -> String {
        var string:String = version.string + " \(status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        if let result:String = try result?.string() {
            let content_length:Int = result.count - result.ranges(of: "\\").count
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.rawValue + (charset != nil ? "; charset=" + charset! : "") + "\\r\\n"
            }
            string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
            string += "\\r\\n\\r\\n" + result
        }
        return string
    }

    @inlinable
    public func bytes() throws -> [UInt8] {
        var string:String = version.string + " \(status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        var bytes:[UInt8]
        if let result:[UInt8] = try result?.bytes() {
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.rawValue + (charset != nil ? "; charset=" + charset! : "") + "\\r\\n"
            }
            string += HTTPField.Name.contentLength.rawName + ": \(result.count)"
            string += "\\r\\n\\r\\n"
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: result)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes
    }
}