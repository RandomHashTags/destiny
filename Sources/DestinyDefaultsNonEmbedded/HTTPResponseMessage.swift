
import DestinyBlueprint
import DestinyDefaults

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: HTTPMessageProtocol {
    public var head:HTTPResponseMessageHead<HTTPCookie>
    public var body:(any ResponseBodyProtocol)?
    public var contentType:String?
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) {
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        self.contentType = contentType
        self.charset = charset
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
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }
    public init(
        head: HTTPResponseMessageHead<HTTPCookie>,
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) {
        self.head = head
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }

    #if Inlinable
    @inlinable
    #endif
    public var version: HTTPVersion {
        get { head.version }
        set { head.version = newValue }
    }

    #if Inlinable
    @inlinable
    #endif
    public func statusCode() -> HTTPResponseStatus.Code {
        head.status
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        head.status = code
    }

    #if Inlinable
    @inlinable
    #endif
    public func string(
        escapeLineBreak: Bool
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            var bodyString = body.string()
            bodyString.replace("\"", with: "\\\"")
            if let contentType {
                string += "content-type: \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            if body.hasContentLength {
                let contentLength = bodyString.utf8Span.count
                string += "content-length: \(contentLength)\(suffix)\(suffix)\(bodyString)"
            } else {
                string += "\(suffix)\(bodyString)"
            }
        }
        return string
    }

    #if Inlinable
    @inlinable
    #endif
    public func intermediateString(escapeLineBreak: Bool) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            if let contentType {
                string += "content-type: \(contentType)\((charset != nil ? "; charset=\(charset!.rawName)" : ""))\(suffix)"
            }
            if body.hasContentLength {
                string += "content-length: \(body.count)\(suffix)\(suffix)"
            }
        }
        return string
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setHeader(key: String, value: String) {
        head.headers[key] = value
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func appendCookie(_ cookie: some HTTPCookieProtocol) throws(HTTPCookieError) {
        try head.cookies.append(.init(copying: cookie))
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        self.body = body
    }
}

// MARK: Temp allocation
extension HTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public func temporaryAllocation<E: Error>(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws(E) -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in head.headers {
            capacity += 4 + key.utf8Span.count + value.utf8Span.count // Header: Value\r\n
        }
        var contentTypeDescription:String
        var charsetRawName:String
        var contentLengthString:String
        if let body {
            if let contentType {
                contentTypeDescription = contentType
                capacity += 16 + contentTypeDescription.utf8Span.count // "Content-Type: x\r\n"
                if let charset {
                    charsetRawName = charset.rawName
                    capacity += 10 + charsetRawName.utf8Span.count // "; charset=x"
                } else {
                    charsetRawName = ""
                }
            } else {
                contentTypeDescription = ""
                charsetRawName = ""
            }
            let bodyCount = body.count
            contentLengthString = String(bodyCount)
            capacity += 20 + contentLengthString.utf8Span.count + bodyCount // "Content-Length: #\r\n\r\n" + content
        } else {
            contentTypeDescription = ""
            contentLengthString = ""
            charsetRawName = ""
        }
        let cookieDescriptions = head.cookieDescriptions()
        for cookie in cookieDescriptions {
            capacity += 14 + cookie.utf8Span.count // Set-Cookie: x\r\n
        }
        try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            writeStartLine(to: p, index: &i)
            for (key, value) in head.headers {
                writeHeader(to: p, index: &i, key: key, value: value)
            }
            for cookie in cookieDescriptions {
                writeCookie(to: p, index: &i, cookie: cookie)
            }
            try writeResult(
                to: p,
                index: &i,
                contentTypeDescription: contentTypeDescription,
                charsetRawName: charsetRawName,
                contentLengthString: contentLengthString
            )
            try closure(p)
        })
    }

    #if Inlinable
    @inlinable
    #endif
    func writeString(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, string: String) {
        let span = string.utf8Span.span
        for j in span.indices {
            buffer[i] = span[unchecked: j]
            i += 1
        }
    }

    /// Writes `\r` and `\n` to the buffer.
    #if Inlinable
    @inlinable
    #endif
    func writeCRLF(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        buffer[i] = .carriageReturn
        i += 1
        buffer[i] = .lineFeed
        i += 1
    }

    #if Inlinable
    @inlinable
    #endif
    func writeStartLine(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        writeInlineArray(to: buffer, index: &i, array: head.version.inlineArray)
        buffer[i] = .space
        i += 1

        let statusString = String(head.status)
        writeString(to: buffer, index: &i, string: statusString)
        writeCRLF(to: buffer, index: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, key: String, value: String) {
        writeString(to: buffer, index: &i, string: key)
        buffer[i] = .colon
        i += 1
        buffer[i] = .space
        i += 1

        writeString(to: buffer, index: &i, string: value)
        writeCRLF(to: buffer, index: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeCookie(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, cookie: String) {
        let headerKey:InlineArray<_, UInt8> = [.s, .e, .t, .subtract, .c, .o, .o, .k, .i, .e, .colon, .space]
        writeInlineArray(to: buffer, index: &i, array: headerKey)

        writeString(to: buffer, index: &i, string: cookie)
        writeCRLF(to: buffer, index: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeResult(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        index i: inout Int,
        contentTypeDescription: String,
        charsetRawName: String,
        contentLengthString: String
    ) throws(BufferWriteError) {
        guard var body else { return }
        if contentType != nil {
            let contentTypeHeader:InlineArray<_, UInt8> = [.c, .o, .n, .t, .e, .n, .t, .subtract, .t, .y, .p, .e, .colon, .space]
            writeInlineArray(to: buffer, index: &i, array: contentTypeHeader)

            writeString(to: buffer, index: &i, string: contentTypeDescription)
            if charset != nil {
                let charsetSpan:InlineArray<_, UInt8> = [59, .space, .c, .h, .a, .r, .s, .e, .t, 61] // "; charset="
                writeInlineArray(to: buffer, index: &i, array: charsetSpan)
                writeString(to: buffer, index: &i, string: charsetRawName)
            }
            writeCRLF(to: buffer, index: &i)
        }
        let contentLengthHeader:InlineArray<_, UInt8> = [.c, .o, .n, .t, .e, .n, .t, .subtract, .l, .e, .n, .g, .t, .h, .colon, .space]
        writeInlineArray(to: buffer, index: &i, array: contentLengthHeader)

        writeString(to: buffer, index: &i, string: contentLengthString)
        writeCRLF(to: buffer, index: &i)

        writeCRLF(to: buffer, index: &i)
        try body.write(to: buffer, at: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeInlineArray<let count: Int>(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        index i: inout Int,
        array: InlineArray<count, UInt8>
    ) {
        for j in array.indices {
            buffer[i] = array[unchecked: j]
            i += 1
        }
    }
}

// MARK: Write
extension HTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        var err:SocketError? = nil
        self.temporaryAllocation {
            do throws(SocketError) {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
}

// MARK: Redirect
extension HTTPResponseMessage {
    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP Version of the message.
    ///   - status: HTTP response status of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
    #if Inlinable
    @inlinable
    #endif
    public static func redirect(
        to target: String,
        version: HTTPVersion = .v1_1,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.temporaryRedirect.code
    ) -> Self {
        var headers = HTTPHeaders()
        return .redirect(to: target, version: version, status: status, headers: &headers)
    }

    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP version of the message.
    ///   - status: HTTP response status of the message.
    ///   - headers: HTTP headers of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
    #if Inlinable
    @inlinable
    #endif
    public static func redirect(
        to target: String,
        version: HTTPVersion = .v1_1,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.temporaryRedirect.code,
        headers: inout HTTPHeaders
    ) -> Self {
        headers["location"] = "/\(target)"
        return Self(
            version: version, 
            status: status,
            headers: headers,
            cookies: [],
            body: nil,
            contentType: nil,
            charset: nil
        )
    }
}

// MARK: Convenience
extension HTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: some HTTPHeadersProtocol,
        body: String?,
        contentType: String?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), body: body, contentType: contentType, charset: charset)
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
        contentType: String?,
        charset: Charset?
    ) -> String {
        var string = "\(version.string) \(status)\(suffix)\(headers)"
        if let body {
            let contentLength = body.utf8Span.count
            if let contentType {
                string += "content-type: \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            string += "content-length: \(contentLength)\(suffix)\(suffix)\(body)"
        }
        return string
    }


    #if Inlinable
    @inlinable
    #endif
    public static func headers(
        suffix: String,
        headers: some HTTPHeadersProtocol
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += "\(header): \(value)\(suffix)"
        }
        return string
    }
}

#if MediaTypes

// MARK: MediaTypes
import MediaTypes

extension HTTPResponseMessage {
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
    public init(
        head: HTTPResponseMessageHead<HTTPCookie>,
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
        headers: some HTTPHeadersProtocol,
        body: String?,
        mediaType: MediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), body: body, mediaType: mediaType, charset: charset)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: some HTTPHeadersProtocol,
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