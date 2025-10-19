
#if hasFeature(Embedded) || EMBEDDED

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage<
        Body: ResponseBodyProtocol
    >: Sendable {
    public var head:HTTPResponseMessageHead
    public var body:Body?
    public var contentType:String?
    public var charset:Charset?

    public init(
        head: HTTPResponseMessageHead,
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
    public mutating func setBody(_ body: Body) {
        self.body = body
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        guard let body = body as? Body else { return }
        self.body = body
    }
}

#else

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: Sendable {
    public var head:HTTPResponseMessageHead
    public var body:(any ResponseBodyProtocol)?
    public var contentType:String?
    public var charset:Charset?

    public init(
        head: HTTPResponseMessageHead,
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
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        self.body = body
    }
}
#endif

// MARK: Logic
extension HTTPResponseMessage {
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
        var bodyString:String?
        if let body {
            bodyString = body.string()
            bodyString!.replace("\"", with: "\\\"")
        } else {
            bodyString = nil
        }
        return Self.create(
            escapeLineBreak: escapeLineBreak,
            version: version,
            status: head.status,
            headers: head.headers,
            body: bodyString,
            contentType: contentType,
            charset: charset
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setHeader(key: String, value: String) {
        head.headers[key] = value
    }

    #if HTTPCookie
    #if Inlinable
    @inlinable
    #endif
    public mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError) {
        head.cookies.append(cookie)
    }
    #endif
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
        #if HTTPCookie
        return Self(
            head: .init(headers: headers, cookies: [], status: status, version: version),
            body: nil,
            contentType: nil,
            charset: nil
        )
        #else
        return Self(
            head: .init(headers: headers, status: status, version: version),
            body: nil,
            contentType: nil,
            charset: nil
        )
        #endif
    }
}

// MARK: Create
extension HTTPResponseMessage {
    #if Inlinable
    @inlinable
    #endif
    public static func create(
        escapeLineBreak: Bool,
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: HTTPHeaders,
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
        headers: HTTPHeaders
    ) -> String {
        var string = ""
        for (header, value) in headers {
            string += "\(header): \(value)\(suffix)"
        }
        return string
    }
}

// MARK: Conformances
extension HTTPResponseMessage: HTTPMessageProtocol {} // TODO: fix?