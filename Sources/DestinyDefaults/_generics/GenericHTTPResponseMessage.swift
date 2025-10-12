
#if GenericHTTPMessage

import DestinyEmbedded
import UnwrapArithmeticOperators

/// Default storage for an HTTP Message.
public struct GenericHTTPResponseMessage<
        Body: ResponseBodyProtocol,
        Cookie: HTTPCookieProtocol
    > {
    public var head:HTTPResponseMessageHead<Cookie>
    public var body:Body?
    public var contentType:String?
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [Cookie],
        body: Body?,
        contentType: String?,
        charset: Charset?
    ) {
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }
    public init(
        head: HTTPResponseMessageHead<Cookie>,
        body: Body?,
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
    public mutating func setHeader(key: String, value: String) {
        head.headers[key] = value
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func appendCookie(_ cookie: Cookie) {
        head.cookies.append(cookie)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        guard let body = body as? Body else { return }
        self.body = body
    }
}

// MARK: Temp allocation
extension GenericHTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public func temporaryAllocation<E: Error>(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws(E) -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in head.headers {
            capacity +=! (4 +! key.utf8Span.count +! value.utf8Span.count) // Header: Value\r\n
        }
        var contentTypeDescription:String
        var charsetRawName:String
        var contentLengthString:String
        if let body {
            if let contentType {
                contentTypeDescription = contentType
                capacity +=! (16 +! contentTypeDescription.utf8Span.count) // "Content-Type: x\r\n"
                if let charset {
                    charsetRawName = charset.rawName
                    capacity +=! (10 +! charsetRawName.utf8Span.count) // "; charset=x"
                } else {
                    charsetRawName = ""
                }
            } else {
                contentTypeDescription = ""
                charsetRawName = ""
            }
            let bodyCount = body.count
            contentLengthString = String(bodyCount)
            capacity +=! (20 +! contentLengthString.utf8Span.count +! bodyCount) // "Content-Length: #\r\n\r\n" + content
        } else {
            contentTypeDescription = ""
            contentLengthString = ""
            charsetRawName = ""
        }
        let cookieDescriptions = head.cookieDescriptions()
        for cookie in cookieDescriptions {
            capacity +=! (14 +! cookie.utf8Span.count) // Set-Cookie: x\r\n
        }
        try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            writeStartLine(to: p, at: &i)
            for (key, value) in head.headers {
                writeHeader(to: p, at: &i, key: key, value: value)
            }
            for cookie in cookieDescriptions {
                writeCookie(cookie, to: p, at: &i)
            }
            try writeResult(
                to: p,
                index: &i,
                contentTypeDescription: &contentTypeDescription,
                charsetRawName: &charsetRawName,
                contentLengthString: &contentLengthString
            )
            try closure(p)
        })
    }

    #if Inlinable
    @inlinable
    #endif
    func writeString(_ string: String, to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        let span = string.utf8Span.span
        for j in span.indices {
            buffer[i] = span[unchecked: j]
            i +=! 1
        }
    }

    /// Writes `\r` and `\n` to the buffer.
    #if Inlinable
    @inlinable
    #endif
    func writeCRLF(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        buffer[i] = .carriageReturn
        i +=! 1
        buffer[i] = .lineFeed
        i +=! 1
    }

    #if Inlinable
    @inlinable
    #endif
    func writeStartLine(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        writeStaticString(head.version.staticString, to: buffer, at: &i)
        buffer[i] = .space
        i +=! 1

        let statusString = String(head.status)
        writeString(statusString, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int, key: String, value: String) {
        writeString(key, to: buffer, at: &i)
        buffer[i] = .colon
        i +=! 1
        buffer[i] = .space
        i +=! 1

        writeString(value, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeCookie(_ cookie: String, to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        writeStaticString("set-cookie: ", to: buffer, at: &i)
        writeString(cookie, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeResult(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        index i: inout Int,
        contentTypeDescription: inout String,
        charsetRawName: inout String,
        contentLengthString: inout String
    ) throws(BufferWriteError) {
        guard var body else { return }
        if contentType != nil {
            writeStaticString("content-type: ", to: buffer, at: &i)
            writeString(contentTypeDescription, to: buffer, at: &i)
            if charset != nil {
                writeStaticString("; charset=", to: buffer, at: &i)
                writeString(charsetRawName, to: buffer, at: &i)
            }
            writeCRLF(to: buffer, at: &i)
        }
        writeStaticString("content-length: ", to: buffer, at: &i)
        writeString(contentLengthString, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)

        writeCRLF(to: buffer, at: &i)
        try body.write(to: buffer, at: &i)
    }

    #if Inlinable
    @inlinable
    #endif
    func writeStaticString(
        _ string: StaticString,
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at i: inout Int
    ) {
        for j in 0..<string.utf8CodeUnitCount {
            buffer[i] = (string.utf8Start + j).pointee
            i +=! 1
        }
    }
}

// MARK: Write
extension GenericHTTPResponseMessage {
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
extension GenericHTTPResponseMessage {
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
        status: HTTPResponseStatus.Code = 307 // temporary redirect
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
        status: HTTPResponseStatus.Code = 307, // temporary redirect
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
extension GenericHTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public static func headers(
        suffix: String,
        headers: HTTPHeaders
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += "\(header): \(value)\(suffix)"
        }
        return string
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension GenericHTTPResponseMessage: GenericHTTPMessageProtocol {}

#endif

#if MediaTypes

// MARK: MediaTypes
import MediaTypes

extension GenericHTTPResponseMessage {
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [Cookie],
        body: Body?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        self.contentType = mediaType?.template
        self.charset = charset
    }
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [Cookie],
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
        cookies: [Cookie],
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
    public init(
        head: HTTPResponseMessageHead<Cookie>,
        body: Body?,
        mediaType: MediaType?,
        charset: Charset?
    ) {
        self.head = head
        self.body = body
        self.contentType = mediaType?.template
        self.charset = charset
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

#endif