
import DestinyBlueprint
import OrderedCollections

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: HTTPMessageProtocol {
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

    public var debugDescription: String {
        """
        HTTPResponseMessage(
            version: .\(version),
            status: \(status),
            headers: \(headers),
            cookies: \(cookies),
            body: \(body?.debugDescription ?? "nil"),
            contentType: \(contentType?.debugDescription ?? "nil"),
            charset: \(charset?.debugDescription ?? "nil")
        )
        """
    }

    @inlinable
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        status = code
    }

    @inlinable
    public func string(
        escapeLineBreak: Bool,
        fromMacro: Bool
    ) throws -> String {
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
            if fromMacro && (body.id == ResponseBody.MacroExpansion<String>.id || body.id == ResponseBody.MacroExpansionWithDateHeader<String>.id) {
                string += "\", body: " + bodyString
            } else {
                string += "\(contentLength)"
                string += suffix + suffix
                string += bodyString
            }
        }
        return string
    }

    /// - Returns: A byte array representing an HTTP Message with the given values.
    @inlinable
    public func bytes() throws -> [UInt8] {
        let suffix = String([Character(Unicode.Scalar(.carriageReturn)), Character(Unicode.Scalar(.lineFeed))])
        var string = version.string + " \(status)" + suffix
        for (header, value) in headers {
            string += header + ": " + value + suffix
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)" + suffix
        }
        var bytes:[UInt8]
        if let body = try body?.bytes() {
            if let contentType {
                string.append(HTTPResponseHeader.contentType.rawName)
                string += ": \(contentType)" + (charset != nil ? "; charset=" + charset!.rawName : "") + suffix
            }
            string.append(HTTPResponseHeader.contentLength.rawName)
            string += ": \(body.count)"
            string += suffix + suffix
            
            bytes = [UInt8](string.utf8)
            bytes.append(contentsOf: body)
        } else {
            bytes = [UInt8](string.utf8)
        }
        return bytes
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
    public mutating func setBody(_ body: String) {
        self.body = ResponseBody.string(body)
    }
}

// MARK: Write
extension HTTPResponseMessage {
    @inlinable
    public func withUnsafeTemporaryAllocation(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        var capacity = 14 // HTTP/x.x ###\r\n
        for (key, value) in headers {
            capacity += 4 + key.count + value.count // Header: Value\r\n
        }
        for cookie in cookies {
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
            for (key, value) in headers {
                writeHeader(to: p, index: &i, key: key, value: value)
            }
            for cookie in cookies {
                writeCookie(to: p, index: &i, cookie: cookie)
            }
            writeResult(to: p, index: &i)
            try closure(p)
        })
    }
    @inlinable
    func writeCRLF(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        buffer[i] = .carriageReturn
        i += 1
        buffer[i] = .lineFeed
        i += 1
    }
    @inlinable
    func writeStartLine(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        let versionArray = version.inlineArray
        for indice in versionArray.indices {
            buffer[i + indice] = versionArray[indice]
        }
        i += 8
        buffer[i] = .space
        i += 1

        let span = String(status).utf8Span.span
        for indice in span.indices {
            buffer[i + indice] = span[indice]
        }
        i += span.count
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, key: String, value: String) {
        let keySpan = key.utf8Span.span
        for indice in keySpan.indices {
            buffer[i + indice] = keySpan[indice]
        }
        i += keySpan.count
        buffer[i] = .colon
        i += 1
        buffer[i] = .space
        i += 1

        let valueSpan = value.utf8Span.span
        for indice in valueSpan.indices {
            buffer[i + indice] = valueSpan[indice]
        }
        i += valueSpan.count
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeCookie(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int, cookie: any HTTPCookieProtocol) {
        let span = "\(cookie)".utf8Span.span
        let headerKey:InlineArray<12, UInt8> = #inlineArray("Set-Cookie: ")
        for indice in headerKey.indices {
            buffer[i + indice] = headerKey[indice]
        }
        i += 12
        for indice in span.indices {
            buffer[i + indice] = span[indice]
        }
        i += span.count
        writeCRLF(to: buffer, index: &i)
    }
    @inlinable
    func writeResult(to buffer: UnsafeMutableBufferPointer<UInt8>, index i: inout Int) {
        guard let body else { return }
        let contentLength = body.count
        if let contentType {
            let contentTypeHeader:InlineArray<14, UInt8> = #inlineArray("Content-Type: ")
            for indice in contentTypeHeader.indices {
                buffer[i + indice] = contentTypeHeader[indice]
            }
            i += 14
            let contentTypeSpan = contentType.description.utf8Span.span
            for indice in contentTypeSpan.indices {
                buffer[i + indice] = contentTypeSpan[indice]
            }
            i += contentTypeSpan.count
            if let charset {
                let charsetSpan:InlineArray<10, UInt8> = #inlineArray("; charset=")
                for indice in charsetSpan.indices {
                    buffer[i + indice] = charsetSpan[indice]
                }
                i += charsetSpan.count
                let charsetValueSpan = charset.rawName.utf8Span.span
                for indice in charsetValueSpan.indices {
                    buffer[i + indice] = charsetValueSpan[indice]
                }
                i += charsetValueSpan.count
            }
            writeCRLF(to: buffer, index: &i)
        }
        let contentLengthHeader:InlineArray<16, UInt8> = #inlineArray("Content-Length: ")
        for indice in contentLengthHeader.indices {
            buffer[i + indice] = contentLengthHeader[indice]
        }
        i += 16 // contentLengthHeader
        let contentLengthSpan = String(contentLength).utf8Span.span
        for indice in contentLengthSpan.indices {
            buffer[i + indice] = contentLengthSpan[indice]
        }
        i += contentLengthSpan.count
        writeCRLF(to: buffer, index: &i)

        writeCRLF(to: buffer, index: &i)
        body.bytes {
            for indice in $0.indices {
                buffer[i + indice] = $0.itemAt(index: indice)
            }
        }
    }

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
        headers: [String:String],
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
        headers: [HTTPResponseHeader:String],
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
        headers: [String:String]
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
        headers: [HTTPResponseHeader:String]
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += header.rawValue + ": " + value + suffix
        }
        return string
    }
}