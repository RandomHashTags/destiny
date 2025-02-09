//
//  DestinyDefaults.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

#if canImport(DestinyUtilities)
import DestinyUtilities
#endif

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
        let suffix:String = escapeLineBreak ? "\\r\\n" : "\r\n"
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
        let suffix:String = escapeLineBreak ? "\\r\\n" : "\r\n"
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
        var string:String = version.string() + " \(status)" + suffix + headers
        if let result:String = result {
            let content_length:Int = result.utf8.count
            if let contentType:HTTPMediaType = contentType {
                string += HTTPResponseHeader.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string += HTTPResponseHeader.contentLength.rawName + ": \(content_length)"
            string += suffix + suffix + result
        }
        return string
    }
    

    @inlinable
    public static func headers(
        suffix: String,
        headers: [String:String]
    ) -> String {
        var string:String = ""
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
        var string:String = ""
        for (header, value) in headers {
            string += header.rawValue + ": " + value + suffix
        }
        return string
    }
}