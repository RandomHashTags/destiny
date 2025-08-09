
import DestinyBlueprint

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: HTTPMessageProtocol {
    public var head:HTTPResponseMessageHead
    public var body:(any ResponseBodyProtocol)?
    public var contentType:HTTPMediaType?
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [any HTTPCookieProtocol],
        body: (any ResponseBodyProtocol)?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) {
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
        cookies: [any HTTPCookieProtocol],
        body: (any ResponseBodyProtocol)?,
        contentType: (some HTTPMediaTypeProtocol)?,
        charset: Charset?
    ) {
        head = .init(headers: headers, cookies: cookies, status: status, version: version)
        self.body = body
        if let contentType {
            self.contentType = .init(contentType)
        } else {
            self.contentType = nil
        }
        self.charset = charset
    }

    public init(
        headers: HTTPHeaders,
        cookies: [any HTTPCookieProtocol],
        body: (any ResponseBodyProtocol)?,
        contentType: HTTPMediaType?,
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
        head: HTTPResponseMessageHead,
        body: (any ResponseBodyProtocol)?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) {
        self.head = head
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }

    @inlinable
    public var version: HTTPVersion {
        get { head.version }
        set { head.version = newValue }
    }

    @inlinable
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        head.status = code
    }

    @inlinable
    public func string(
        escapeLineBreak: Bool
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            var bodyString = body.string()
            bodyString.replace("\"", with: "\\\"")
            if let contentType {
                string += "\(HTTPStandardResponseHeader.contentType.rawName): \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            if body.hasContentLength {
                let contentLength = bodyString.utf8Span.count
                string += "\(HTTPStandardResponseHeader.contentLength.rawName): \(contentLength)\(suffix)\(suffix)\(bodyString)"
            } else {
                string += "\(suffix)\(bodyString)"
            }
        }
        return string
    }

    @inlinable
    public func intermediateString(escapeLineBreak: Bool) -> String {
        string(escapeLineBreak: escapeLineBreak)
    }

    @inlinable
    public mutating func setHeader(key: String, value: String) {
        head.headers[key] = value
    }

    @inlinable
    public mutating func appendCookie(_ cookie: some HTTPCookieProtocol) {
        head.cookies.append(cookie)
    }

    @inlinable
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        self.body = body
    }
}

// MARK: Temp allocation
extension HTTPResponseMessage {
    @inlinable
    public func temporaryAllocation<E: Error>(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws(E) -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in head.headers {
            capacity += 4 + key.count + value.count // Header: Value\r\n
        }
        var contentTypeDescription:String
        var charsetRawName:String
        var contentLengthString:String
        if let body {
            if let contentType {
                contentTypeDescription = contentType.description
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
        try head.cookieDescriptions { cookieDescriptions in
            for indice in cookieDescriptions.indices {
                capacity += 14 + cookieDescriptions.itemAt(index: indice).utf8Span.count // Set-Cookie: x\r\n
            }
            try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
                var i = 0
                writeStartLine(to: p, index: &i)
                for (key, value) in head.headers {
                    writeHeader(to: p, index: &i, key: key, value: value)
                }
                for indice in cookieDescriptions.indices {
                    writeCookie(to: p, index: &i, cookie: cookieDescriptions.itemAt(index: indice))
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
    }

    @inlinable
    func writeString(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, string: String) {
        string.utf8Span.span.withUnsafeBufferPointer {
            $0.forEach {
                buffer[i] = $0
                i += 1
            }
        }
    }

    /// Writes `\r` and `\n` to the buffer.
    @inlinable
    func writeCRLF(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        buffer[i] = .carriageReturn
        i += 1
        buffer[i] = .lineFeed
        i += 1
    }
    @inlinable
    func writeStartLine(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        writeInlineArray(to: buffer, index: &i, array: head.version.inlineByteArray)
        buffer[i] = .space
        i += 1

        let statusString = String(head.status)
        writeString(to: buffer, index: &i, string: statusString)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, key: String, value: String) {
        writeString(to: buffer, index: &i, string: key)
        buffer[i] = .colon
        i += 1
        buffer[i] = .space
        i += 1

        writeString(to: buffer, index: &i, string: value)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeCookie(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, cookie: String) {
        let headerKey:InlineByteArray<12> = .init([83, 101, 116, 45, 67, 111, 111, 107, 105, 101, 58, 32]) // "Set-Cookie: "
        writeInlineArray(to: buffer, index: &i, array: headerKey)

        writeString(to: buffer, index: &i, string: cookie)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeResult(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        index i: inout Int,
        contentTypeDescription: String,
        charsetRawName: String,
        contentLengthString: String
    ) throws(BufferWriteError) {
        guard var body else { return }
        if contentType != nil {
            let contentTypeHeader:InlineByteArray<14> = .init([67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32]) // "Content-Type: "
            writeInlineArray(to: buffer, index: &i, array: contentTypeHeader)

            writeString(to: buffer, index: &i, string: contentTypeDescription)
            if charset != nil {
                let charsetSpan:InlineByteArray<10> = .init([59, 32, 99, 104, 97, 114, 115, 101, 116, 61]) // "; charset="
                writeInlineArray(to: buffer, index: &i, array: charsetSpan)
                writeString(to: buffer, index: &i, string: charsetRawName)
            }
            writeCRLF(to: buffer, index: &i)
        }
        let contentLengthHeader:InlineByteArray<16> = .init([67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32]) // "Content-Length: "
        writeInlineArray(to: buffer, index: &i, array: contentLengthHeader)

        writeString(to: buffer, index: &i, string: contentLengthString)
        writeCRLF(to: buffer, index: &i)

        writeCRLF(to: buffer, index: &i)
        try body.write(to: buffer, at: &i)
    }
    @inlinable
    func writeInlineArray(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, array: some InlineByteArrayProtocol) {
        for indice in array.indices {
            buffer[i] = array.itemAt(index: indice)
            i += 1
        }
    }
}

// MARK: Write
extension HTTPResponseMessage {
    @inlinable
    public func write(
        to socket: Int32
    ) throws(SocketError) {
        var err:SocketError? = nil
        self.temporaryAllocation {
            do throws(SocketError) {
                try socket.socketWriteBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
}

// MARK: Convenience
extension HTTPResponseMessage {
    @inlinable
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: some HTTPHeadersProtocol,
        body: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), body: body, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: some HTTPHeadersProtocol,
        body: String?,
        contentType: (some HTTPMediaTypeProtocol)?,
        charset: Charset?
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        return create(suffix: suffix, version: version, status: status, headers: Self.headers(suffix: suffix, headers: headers), body: body, contentType: contentType, charset: charset)
    }

    @inlinable
    public static func create(
        suffix: String,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: String,
        body: String?,
        contentType: (some HTTPMediaTypeProtocol)?,
        charset: Charset?
    ) -> String {
        var string = "\(version.string) \(status)\(suffix)\(headers)"
        if let body {
            let contentLength = body.utf8.count
            //let test = body.utf8Span.count // TODO: crashes LSP
            if let contentType {
                string += "\(HTTPStandardResponseHeader.contentType.rawName): \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            string += "\(HTTPStandardResponseHeader.contentLength.rawName): \(contentLength)\(suffix)\(suffix)\(body)"
        }
        return string
    }


    @inlinable
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