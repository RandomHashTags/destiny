
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
    public func string(escapeLineBreak: Bool) throws -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            var bodyString = body.string()
            let contentLength = bodyString.utf8.count
            bodyString.replace("\"", with: "\\\"")
            if let contentType {
                string += "\(HTTPResponseHeader.contentType.rawName.string()): \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            if body.hasContentLength {
                string += "\(HTTPResponseHeader.contentLength.rawName.string()): "
            }
            if let customInitializer = body.customInitializer(bodyString: bodyString) {
                string += customInitializer
            } else {
                string += "\(contentLength)\(suffix)\(suffix)\(bodyString)"
            }
        }
        return string
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

// MARK: Unsafe temp allocation
extension HTTPResponseMessage {
    @inlinable
    public func withUnsafeTemporaryAllocation(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in head.headers {
            capacity += 4 + key.count + value.count // Header: Value\r\n
        }
        for cookie in head.cookies {
            capacity += 14 + "\(cookie)".count // Set-Cookie: x\r\n
        }
        if let body {
            if let contentType {
                capacity += 16 + contentType.description.count + (charset != nil ? 10 + charset!.rawName.count : 0) // Content-Type: x; charset=x\r\n
            }
            let contentLength = body.count
            capacity += 20 + String(contentLength).count + contentLength // "Content-Length: #\r\n\r\n" + content
        }
        try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            writeStartLine(to: p, index: &i)
            for (var key, var value) in head.headers {
                writeHeader(to: p, index: &i, key: &key, value: &value)
            }
            for cookie in head.cookies {
                writeCookie(to: p, index: &i, cookie: cookie)
            }
            try writeResult(to: p, index: &i)
            try closure(p)
        })
    }

    @inlinable
    func writeString(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, string: inout String) {
        // TODO: fix: String utf8Span.span doesn't behave as expected | https://github.com/swiftlang/swift/issues/81931
        /*let span = string.utf8Span.span
        for indice in span.indices {
            buffer[i + indice] = span[indice]
        }
        i += span.count*/
        string.withUTF8 {
            //if $0.count < 64 {
                for indice in 0..<$0.count {
                    buffer[i] = $0[indice]
                    i += 1
                }
            //} else {
            //    buffer.copyBuffer($0, at: &i)
            //}
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
        writeInlineArray(to: buffer, index: &i, array: head.version.inlineArray)
        buffer[i] = .space
        i += 1

        var statusString = String(head.status)
        writeString(to: buffer, index: &i, string: &statusString)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, key: inout String, value: inout String) {
        writeString(to: buffer, index: &i, string: &key)
        buffer[i] = .colon
        i += 1
        buffer[i] = .space
        i += 1

        writeString(to: buffer, index: &i, string: &value)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeCookie(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, cookie: any HTTPCookieProtocol) {
        let headerKey:InlineArray<12, UInt8> = [83, 101, 116, 45, 67, 111, 111, 107, 105, 101, 58, 32] // "Set-Cookie: "
        writeInlineArray(to: buffer, index: &i, array: headerKey)

        var cookieString = "\(cookie)"
        writeString(to: buffer, index: &i, string: &cookieString)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeResult(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) throws {
        guard var body else { return }
        if let contentType {
            let contentTypeHeader:InlineArray<14, UInt8> = [67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32] // "Content-Type: "
            writeInlineArray(to: buffer, index: &i, array: contentTypeHeader)

            var contentTypeDescription = contentType.description
            writeString(to: buffer, index: &i, string: &contentTypeDescription)
            if let charset {
                let charsetSpan:InlineArray<10, UInt8> = [59, 32, 99, 104, 97, 114, 115, 101, 116, 61] // "; charset="
                writeInlineArray(to: buffer, index: &i, array: charsetSpan)

                var charsetValue = charset.rawName
                writeString(to: buffer, index: &i, string: &charsetValue)
            }
            writeCRLF(to: buffer, index: &i)
        }
        let contentLengthHeader:InlineArray<16, UInt8> = [67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32] // "Content-Length: "
        writeInlineArray(to: buffer, index: &i, array: contentLengthHeader)

        var contentLengthString = String(body.count)
        writeString(to: buffer, index: &i, string: &contentLengthString)
        writeCRLF(to: buffer, index: &i)

        writeCRLF(to: buffer, index: &i)
        try body.write(to: buffer, at: &i)
    }
    @inlinable
    func writeInlineArray<T: InlineArrayProtocol>(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, array: T) where T.Element == UInt8 {
        for indice in array.indices {
            buffer[i] = array.itemAt(index: indice)
            i += 1
        }
    }
}

// MARK: Write
extension HTTPResponseMessage {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try self.withUnsafeTemporaryAllocation {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
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
        suffix: String,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: String,
        body: String?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) -> String {
        var string = "\(version.string) \(status)\(suffix)\(headers)"
        if let body {
            let contentLength = body.utf8.count
            if let contentType {
                string += "\(HTTPResponseHeader.contentType.rawName.string()): \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            string += "\(HTTPResponseHeader.contentLength.rawName.string()): \(contentLength)\(suffix)\(suffix)\(body)"
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