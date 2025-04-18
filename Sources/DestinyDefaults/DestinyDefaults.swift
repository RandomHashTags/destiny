//
//  DestinyDefaults.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import DestinyBlueprint
import DestinyUtilities

public enum DestinyDefaults {
    @inlinable
    public static func httpResponse(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: [String:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return httpResponse(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func httpResponse(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: [HTTPResponseHeader:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return httpResponse(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func httpResponse(
        suffix: String,
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: String,
        result: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        var string = version.string + " \(status)" + suffix + headers
        if let result {
            let contentLength = result.utf8.count
            if let contentType {
                string += HTTPResponseHeader.contentType.rawName + ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string += HTTPResponseHeader.contentLength.rawName + ": \(contentLength)"
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