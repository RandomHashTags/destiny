
#if hasFeature(Embedded) || EMBEDDED

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage<
        Body: ResponseBodyProtocol
    >: HTTPSocketWritable {
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

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    public mutating func setBody(_ body: Body) {
        self.body = body
    }

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        guard let body = body as? Body else { return }
        self.body = body
    }
}

#else

/// Default storage for an HTTP Message.
public struct HTTPResponseMessage: HTTPSocketWritable {
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

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        self.body = body
    }
}
#endif

// MARK: Logic
extension HTTPResponseMessage {
    /// Associated HTTP Version of this message.
    public var version: HTTPVersion {
        get { head.version }
        set { head.version = newValue }
    }

    /// - Returns: Current status code this message.
    public func statusCode() -> HTTPResponseStatus.Code {
        head.status
    }

    /// Set the message's status code.
    /// 
    /// - Parameters:
    ///   - code: New status code to set.
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        head.status = code
    }

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the body.
    /// 
    /// - Returns: A string representing an HTTP Message with the given values.
    /// - Throws: `HTTPMessageError`
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

    /// Set a header to the given value.
    /// 
    /// - Parameters:
    ///   - key: Header you want to modify.
    ///   - value: New header value to set.
    public mutating func setHeader(key: String, value: String) {
        head.headers[key] = value
    }

    #if HTTPCookie
    /// - Throws: `HTTPCookieError`
    public mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError) {
        head.cookies.append(cookie)
    }
    #endif
}

// MARK: Redirect
extension HTTPResponseMessage {
    #if hasFeature(Embedded) || EMBEDDED
    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP Version of the message.
    ///   - status: HTTP response status of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
    public static func redirect(
        to target: String,
        version: HTTPVersion = .v1_1,
        status: HTTPResponseStatus.Code = 307 // temporary redirect
    ) -> Self<StaticString> {
        var headers = HTTPHeaders()
        return .redirect(to: target, version: version, status: status, headers: &headers)
    }
    #else
    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP Version of the message.
    ///   - status: HTTP response status of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
    public static func redirect(
        to target: String,
        version: HTTPVersion = .v1_1,
        status: HTTPResponseStatus.Code = 307 // temporary redirect
    ) -> Self {
        var headers = HTTPHeaders()
        return .redirect(to: target, version: version, status: status, headers: &headers)
    }
    #endif

    #if hasFeature(Embedded) || EMBEDDED
    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP version of the message.
    ///   - status: HTTP response status of the message.
    ///   - headers: HTTP headers of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
    public static func redirect(
        to target: String,
        version: HTTPVersion = .v1_1,
        status: HTTPResponseStatus.Code = 307, // temporary redirect
        headers: inout HTTPHeaders
    ) -> Self<StaticString> {
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
    #else
    /// - Parameters:
    ///   - to: Redirection target.
    ///   - version: HTTP version of the message.
    ///   - status: HTTP response status of the message.
    ///   - headers: HTTP headers of the message.
    /// - Returns: A complete `HTTPResponseMessage` that redirects to the target with the given configuration.
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
    #endif
}

// MARK: Create
extension HTTPResponseMessage {
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