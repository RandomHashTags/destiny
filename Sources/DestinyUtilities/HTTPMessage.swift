//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import HTTPTypes

// MARK: HTTPMessage
/// The default storage for a HTTP Message.
public struct HTTPMessage : Sendable, CustomDebugStringConvertible {
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
        contentType: (any HTTPMediaTypeProtocol)?,
        charset: String?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.result = result
        self.contentType = contentType?.structure
        self.charset = charset
    }

    public var debugDescription : String {
        return "HTTPMessage(version: \(version), status: \(status.debugDescription), headers: \(headers), result: \(result?.debugDescription ?? "nil"), contentType: \(contentType?.debugDescription ?? ""), charset: \(charset != nil ? "\"" + charset! + "\"" : "nil"))" // TODO: fix
    }

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable
    public func string(escapeLineBreak: Bool) throws -> String {
        let suffix:String = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string:String = version.string() + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        if let result:String = try result?.string() {
            let content_length:Int = result.utf8.count
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset! : "") + suffix
            }
            string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
            string += suffix + suffix + result
        }
        return string
    }

    /// - Returns: A byte array representing an HTTP Message with the given values.
    @inlinable
    public func bytes() throws -> [UInt8] {
        let suffix:String = String([Character(Unicode.Scalar(13)), Character(Unicode.Scalar(10))]) // \r\n
        var string:String = version.string() + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        var bytes:[UInt8]
        if let result:[UInt8] = try result?.bytes() {
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset! : "") + suffix
            }
            string += HTTPField.Name.contentLength.rawName + ": \(result.count)"
            string += suffix + suffix
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: result)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes
    }
}