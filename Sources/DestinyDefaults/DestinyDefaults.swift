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
        version: HTTPVersion,
        status: HTTPResponse.Status,
        headers: [String:String],
        result: String?,
        contentType: HTTPMediaType?,
        charset: String?
    ) -> String {
        var string:String = version.string + " \(status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        if let result:String = result {
            let content_length:Int = result.count - result.ranges(of: "\\").count
            if let contentType:HTTPMediaType = contentType {
                string += HTTPField.Name.contentType.rawName + ": " + contentType.rawValue + (charset != nil ? "; charset=" + charset! : "") + "\\r\\n"
            }
            string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
            string += "\\r\\n\\r\\n" + result
        }
        return string
    }
}