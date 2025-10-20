
#if (hasFeature(Embedded) || EMBEDDED) && MediaTypes

import MediaTypes

extension HTTPResponseMessage {
    #if HTTPCookie
        public init(
            version: HTTPVersion,
            status: HTTPResponseStatus.Code,
            headers: HTTPHeaders,
            cookies: [HTTPCookie],
            body: Body?,
            mediaType: (some MediaTypeProtocol)?,
            charset: Charset?
        ) {
            head = .init(headers: headers, cookies: cookies, status: status, version: version)
            self.body = body
            if let mediaType {
                self.contentType = mediaType.template
            } else {
                self.contentType = nil
            }
            self.charset = charset
        }

        public init(
            headers: HTTPHeaders,
            cookies: [HTTPCookie],
            body: Body?,
            mediaType: MediaType?,
            status: HTTPResponseStatus.Code,
            version: HTTPVersion,
            charset: Charset?
        ) {
            head = .init(headers: headers, cookies: cookies, status: status, version: version)
            self.body = body
            self.contentType = mediaType?.template
            self.charset = charset
        }
    #else
        public init(
            version: HTTPVersion,
            status: HTTPResponseStatus.Code,
            headers: HTTPHeaders,
            body: Body?,
            mediaType: MediaType?,
            charset: Charset?
        ) {
            head = .init(headers: headers, status: status, version: version)
            self.body = body
            self.contentType = mediaType?.template
            self.charset = charset
        }
        public init(
            version: HTTPVersion,
            status: HTTPResponseStatus.Code,
            headers: HTTPHeaders,
            body: Body?,
            mediaType: (some MediaTypeProtocol)?,
            charset: Charset?
        ) {
            head = .init(headers: headers, status: status, version: version)
            self.body = body
            if let mediaType {
                self.contentType = mediaType.template
            } else {
                self.contentType = nil
            }
            self.charset = charset
        }

        public init(
            headers: HTTPHeaders,
            body: Body?,
            mediaType: MediaType?,
            status: HTTPResponseStatus.Code,
            version: HTTPVersion,
            charset: Charset?
        ) {
            head = .init(headers: headers, status: status, version: version)
            self.body = body
            self.contentType = mediaType?.template
            self.charset = charset
        }
    #endif

    public init(
        head: HTTPResponseMessageHead,
        body: Body?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.head = head
        self.body = body
        self.contentType = mediaType?.template
        self.charset = charset
    }
}

#endif