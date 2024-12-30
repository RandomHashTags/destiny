//
//  DestinyDefaults.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import DestinyUtilities
import HTTPTypes

public enum DestinyDefaults {
    @inlinable
    public static func httpResponse(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponse.Status,
        headers: [String:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: String?
    ) -> String {
        let suffix:String = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string:String = version.string() + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        if let result:String = result {
            let content_length:Int = result.utf8.count
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.httpValue + (charset != nil ? "; charset=" + charset! : "") + suffix
            }
            string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
            string += suffix + suffix + result
        }
        return string
    }
}