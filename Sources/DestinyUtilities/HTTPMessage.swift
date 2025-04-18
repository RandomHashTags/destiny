//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

// MARK: HTTPMessage
/// Default storage for an HTTP Message.
public struct HTTPMessage : CustomDebugStringConvertible, Sendable {
    public var headers:[String:String]
    public var cookies:[any HTTPCookieProtocol]
    public var result:RouteResult?
    public var contentType:HTTPMediaType?
    public var version:HTTPVersion
    public var status:HTTPResponseStatus
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: [String:String],
        cookies: [any HTTPCookieProtocol],
        result: RouteResult?,
        contentType: (any HTTPMediaTypeProtocol)?,
        charset: Charset?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.cookies = cookies
        self.result = result
        self.contentType = contentType?.structure
        self.charset = charset
    }

    public var debugDescription : String {
        return "HTTPMessage(version: .\(version), status: \(status.debugDescription), headers: \(headers), cookies: \(cookies), result: \(result?.debugDescription ?? "nil"), contentType: \(contentType?.debugDescription ?? ""), charset: \(charset?.debugDescription ?? "nil"))" // TODO: fix
    }

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable
    public func string(escapeLineBreak: Bool) throws -> String {
        let suffix:String = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string:String = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        if var result = try result?.string() {
            let contentLength = result.utf8.count
            result.replace("\"", with: "\\\"")
            if let contentType {
                string += HTTPResponseHeader.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string += HTTPResponseHeader.contentLength.rawName + ": \(contentLength)"
            string += suffix + suffix + result
        }
        return string
    }

    /// - Returns: A byte array representing an HTTP Message with the given values.
    @inlinable
    public func bytes() throws -> [UInt8] {
        let suffix:String = String([Character(Unicode.Scalar(13)), Character(Unicode.Scalar(10))]) // \r\n
        var string:String = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        var bytes:[UInt8]
        if let result:[UInt8] = try result?.bytes() {
            if let contentType {
                string += HTTPResponseHeader.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string += HTTPResponseHeader.contentLength.rawName + ": \(result.count)"
            string += suffix + suffix
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: result)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes
    }
}