
import DestinyBlueprint
import OrderedCollections

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: HTTPMessageProtocol, CustomDebugStringConvertible {
    public var headers:OrderedDictionary<String, String>
    public var cookies:[any HTTPCookieProtocol]
    public var body:(any ResponseBodyProtocol)?
    public var contentType:HTTPMediaType?
    public var status:HTTPResponseStatus.Code
    public var version:HTTPVersion
    public var charset:Charset?

    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: OrderedDictionary<String, String>,
        cookies: [any HTTPCookieProtocol],
        body: (any ResponseBodyProtocol)?,
        contentType: HTTPMediaType?,
        charset: Charset?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.cookies = cookies
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }
    public init(
        headers: OrderedDictionary<String, String>,
        cookies: [any HTTPCookieProtocol],
        body: (any ResponseBodyProtocol)?,
        contentType: HTTPMediaType?,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion,
        charset: Charset?
    ) {
        self.version = version
        self.status = status
        self.headers = headers
        self.cookies = cookies
        self.body = body
        self.contentType = contentType
        self.charset = charset
    }

    public var debugDescription: String {
        """
        HTTPResponseMessage(
            version: .\(version),
            status: \(status),
            headers: \(headers),
            cookies: \(cookies),
            body: \(body != nil ? "\(body!)" : "nil"),
            contentType: \(contentType != nil ? "\(contentType!)" : "nil"),
            charset: \(charset != nil ? "\(charset!)" :  "nil")
        )
        """
    }


    @inlinable
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        status = code
    }

    @inlinable
    public func string(escapeLineBreak: Bool) throws -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        if let body {
            var bodyString = try body.string()
            let contentLength = bodyString.utf8.count
            bodyString.replace("\"", with: "\\\"")
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": "
            if body.hasCustomInitializer {
                string += body.customInitializer(bodyString: bodyString)
            } else {
                string += "\(contentLength)"
                string += suffix + suffix
                string += bodyString
            }
        }
        return string
    }

    @inlinable
    public mutating func setHeader(key: String, value: String) {
        headers[key] = value
    }

    @inlinable
    public mutating func appendCookie<T: HTTPCookieProtocol>(_ cookie: T) {
        cookies.append(cookie)
    }

    @inlinable
    public mutating func setBody<T: ResponseBodyProtocol>(_ body: T) {
        self.body = body
    }
}

// MARK: Unsafe temp allocation
extension HTTPResponseMessage {
    @inlinable
    public func withUnsafeTemporaryAllocation(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in headers {
            capacity += 4 + key.count + value.count // Header: Value\r\n
        }
        for cookie in cookies {
            // TODO: fix? Cookie interpolation crashes when ran in debug mode due to "bad pointer dereference" (doesn't crash in release mode)
            capacity += 14 + "\(cookie)".count // Set-Cookie: x\r\n
        }
        if let body {
            if let contentType {
                capacity += 16 + contentType.description.count + (charset != nil ? 10 + charset!.rawName.count : 0) // Content-Type: x; charset=x\r\n
            }
            let contentLength = body.count
            capacity += 18 + String(contentLength).count // Content-Length: #\r\n
            capacity += 2 + contentLength // \r\n + content
        }
        try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            writeStartLine(to: p, index: &i)
            for (var key, var value) in headers {
                writeHeader(to: p, index: &i, key: &key, value: &value)
            }
            for cookie in cookies {
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
        writeInlineArray(to: buffer, index: &i, array: version.inlineArray)
        buffer[i] = .space
        i += 1

        var statusString = String(status)
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
        let headerKey:InlineArray<12, UInt8> = #inlineArray("Set-Cookie: ")
        writeInlineArray(to: buffer, index: &i, array: headerKey)

        var cookieString = "\(cookie)"
        writeString(to: buffer, index: &i, string: &cookieString)
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeResult(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) throws {
        guard var body else { return }
        if let contentType {
            let contentTypeHeader:InlineArray<14, UInt8> = #inlineArray("Content-Type: ")
            writeInlineArray(to: buffer, index: &i, array: contentTypeHeader)

            var contentTypeDescription = contentType.description
            writeString(to: buffer, index: &i, string: &contentTypeDescription)
            if let charset {
                let charsetSpan:InlineArray<10, UInt8> = #inlineArray("; charset=")
                writeInlineArray(to: buffer, index: &i, array: charsetSpan)

                var charsetValue = charset.rawName
                writeString(to: buffer, index: &i, string: &charsetValue)
            }
            writeCRLF(to: buffer, index: &i)
        }
        let contentLengthHeader:InlineArray<16, UInt8> = #inlineArray("Content-Length: ")
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
    public func write<Socket: HTTPSocketProtocol & ~Copyable>(to socket: borrowing Socket) throws {
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
        headers: OrderedDictionary<String, String>,
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
        headers: OrderedDictionary<HTTPResponseHeader, String>,
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
        var string = version.string + " \(status)" + suffix + headers
        if let body {
            let contentLength = body.utf8.count
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(contentLength)"
            string += suffix + suffix + body
        }
        return string
    }


    @inlinable
    public static func headers(
        suffix: String,
        headers: OrderedDictionary<String, String>
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        return string
    }

    @inlinable
    public static func headers(
        suffix: String,
        headers: OrderedDictionary<HTTPResponseHeader, String>
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += header.rawValue + ": " + value + suffix
        }
        return string
    }
}