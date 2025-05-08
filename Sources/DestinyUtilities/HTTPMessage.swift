//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import DestinyBlueprint

// MARK: HTTPMessage
/// Default storage for an HTTP Message.
public struct HTTPMessage: HTTPMessageProtocol {
    public var headers:[String:String]
    public var cookies:[any HTTPCookieProtocol]
    public var result:RouteResult?
    public var contentType:HTTPMediaType?
    public var status:HTTPResponseStatus.Code
    public var version:HTTPVersion
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: [String:String],
        cookies: [any HTTPCookieProtocol],
        result: RouteResult?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.cookies = cookies
        self.result = result
        self.contentType = contentType
        self.charset = charset
    }

    public var debugDescription: String {
        "HTTPMessage(version: .\(version), status: \(status), headers: \(headers), cookies: \(cookies), result: \(result?.debugDescription ?? "nil"), contentType: \(contentType?.debugDescription ?? "nil"), charset: \(charset?.debugDescription ?? "nil"))" // TODO: fix
    }

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable
    public func string(escapeLineBreak: Bool) throws -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = version.string + " \(status)" + suffix
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
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(contentLength)"
            string += suffix + suffix + result
        }
        return string
    }

    /// - Returns: A byte array representing an HTTP Message with the given values.
    @inlinable
    public func bytes() throws -> [UInt8] {
        let suffix = String([Character(Unicode.Scalar(.carriageReturn)), Character(Unicode.Scalar(.lineFeed))])
        var string = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        var bytes:[UInt8]
        if let result = try result?.bytes() {
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(result.count)"
            string += suffix + suffix
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: result)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes
    }

    @inlinable
    public func bytes(_ closure: (InlineVLArray<UInt8>) throws -> Void) rethrows {
        let suffix = String([Character(Unicode.Scalar(.carriageReturn)), Character(Unicode.Scalar(.lineFeed))])
        var string = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        var byteCount = 0
        if let result {
            try result.bytes { array in
            }
        } else {
        }
        // TODO: finish
        /*var bytes:[UInt8]
        if let result = try result?.bytes() {
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(result.count)"
            string += suffix + suffix
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: result)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes*/
    }

    @inlinable
    public mutating func setHeader(key: String, value: String) {
        headers[key] = value
    }

    @inlinable
    public mutating func appendCookie<T: HTTPCookieProtocol>(_ cookie: T) {
        cookies.append(cookie)
    }

    @inlinable
    public mutating func assignResult(_ string: String) {
        result = .string(string)
    }
}

// MARK: Convenience
extension HTTPMessage {
    @inlinable
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: [String:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: [HTTPResponseHeader:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func create(
        suffix: String,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: String,
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        var string = version.string + " \(status)" + suffix + headers
        if let result {
            let contentLength = result.utf8.count
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(contentLength)"
            string += suffix + suffix + result
        }
        return string
    }


    @inlinable
    public static func headers(
        suffix: String,
        headers: [String:String]
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        return string
    }

    @inlinable
    public static func headers(
        suffix: String,
        headers: [HTTPResponseHeader:String]
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += header.rawValue + ": " + value + suffix
        }
        return string
    }
}