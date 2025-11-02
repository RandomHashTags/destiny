
import UnwrapArithmeticOperators

// MARK: Temp allocation
extension HTTPResponseMessage {
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

        #if HTTPCookie
        let cookieDescriptions = head.cookieDescriptions()
        for cookie in cookieDescriptions {
            capacity +=! (14 +! cookie.utf8Span.count) // Set-Cookie: x\r\n
        }
        #endif

        try Swift.withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            writeStartLine(to: p, at: &i)
            for (key, value) in head.headers {
                writeHeader(to: p, at: &i, key: key, value: value)
            }

            #if HTTPCookie
            for cookie in cookieDescriptions {
                writeCookie(cookie, to: p, at: &i)
            }
            #endif

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

    func writeString(_ string: String, to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        let span = string.utf8Span.span
        for j in span.indices {
            buffer[i] = span[unchecked: j]
            i +=! 1
        }
    }

    /// Writes `\r` and `\n` to the buffer.
    func writeCRLF(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        buffer[i] = .carriageReturn
        i +=! 1
        buffer[i] = .lineFeed
        i +=! 1
    }

    func writeStartLine(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        writeStaticString(head.version.staticString, to: buffer, at: &i)
        buffer[i] = .space
        i +=! 1

        let statusString = String(head.status)
        writeString(statusString, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    func writeHeader(to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int, key: String, value: String) {
        writeString(key, to: buffer, at: &i)
        buffer[i] = .colon
        i +=! 1
        buffer[i] = .space
        i +=! 1

        writeString(value, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    func writeCookie(_ cookie: String, to buffer: UnsafeMutableBufferPointer<UInt8>, at i: inout Int) {
        writeStaticString("set-cookie: ", to: buffer, at: &i)
        writeString(cookie, to: buffer, at: &i)
        writeCRLF(to: buffer, at: &i)
    }

    /// - Throws: `BufferWriteError`
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
extension HTTPResponseMessage {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
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