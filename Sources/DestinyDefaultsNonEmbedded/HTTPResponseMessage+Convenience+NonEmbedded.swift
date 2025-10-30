
import DestinyEmbedded

#if MediaTypes

import MediaTypes

// MARK: MediaTypes
extension HTTPResponseMessage {
    public init(
        head: HTTPResponseMessageHead,
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.init(head: head, body: body, contentType: mediaType?.template, charset: charset)
    }
    public init(
        head: HTTPResponseMessageHead,
        body: (any ResponseBodyProtocol)?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) {
        self.init(head: head, body: body, contentType: mediaType?.template, charset: charset)
    }

    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        body: String?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), body: body, mediaType: mediaType, charset: charset)
    }

    public static func create(
        suffix: String,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: String,
        body: String?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) -> String {
        var string = "\(version.string) \(status)\(suffix)\(headers)"
        if let body {
            let contentLength = body.utf8Span.count
            if let mediaType {
                string += "content-type: \(mediaType.template)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            string += "content-length: \(contentLength)\(suffix)\(suffix)\(body)"
        }
        return string
    }
}

#endif