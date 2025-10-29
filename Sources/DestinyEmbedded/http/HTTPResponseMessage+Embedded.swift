
#if (hasFeature(Embedded) || EMBEDDED) && MediaTypes

import MediaTypes

extension HTTPResponseMessage {
    public init(
        head: HTTPResponseMessageHead,
        body: Body?,
        mediaType: (some MediaTypeProtocol)?,
        charset: Charset?
    ) {
        self.head = head
        self.body = body
        self.contentType = mediaType?.template
        self.charset = charset
    }

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