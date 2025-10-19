
import DestinyEmbedded

// MARK: Init
extension HTTPResponseMessage {
    #if HTTPCookie
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) {
        self.init(
            head: .init(headers: headers, cookies: cookies, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }

    public init(
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion,
        charset: Charset?
    ) {
        self.init(
            head: .init(headers: headers, cookies: cookies, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }
    #else
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) {
        self.init(
            head: .init(headers: headers, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }

    public init(
        headers: HTTPHeaders,
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion,
        charset: Charset?
    ) {
        self.init(
            head: .init(headers: headers, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }
    #endif
}

#if MediaTypes

import MediaTypes

// MARK: MediaTypes
extension HTTPResponseMessage {
    #if HTTPCookie
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: mediaType?.template, charset: charset)
    }
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: mediaType?.template, charset: charset)
    }
    public init(
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: mediaType?.template, charset: charset)
    }
    #else
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, body: body, contentType: mediaType?.template, charset: charset)
    }
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        body: (any ResponseBodyProtocol)?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, body: body, contentType: mediaType?.template, charset: charset)
    }
    public init(
        headers: HTTPHeaders,
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion,
        charset: Charset?
    ) {
        self.init(version: version, status: status, headers: headers, body: body, contentType: mediaType?.template, charset: charset)
    }
    #endif

    public init(
        head: HTTPResponseMessageHead,
        body: (any ResponseBodyProtocol)?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.init(head: head, body: body, contentType: mediaType?.template, charset: charset)
    }

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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