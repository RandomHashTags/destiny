
import DestinyBlueprint

// MARK: HTTPRequestHeaders
/// Default storage for HTTP request headers.
public struct HTTPRequestHeaders: HTTPRequestHeadersProtocol { // TODO: make SIMD
    public typealias Key = String
    public typealias Value = String

    // TODO: arrange for optimal memory layout
    @usableFromInline var custom:[String:String] = [:]

    public var accept:String?
    public var acceptCharset:Charset?
    public var acceptDatetimeString:String?
    public var acceptEncoding:HTTPRequestHeader.AcceptEncoding?
    public var contentLength:Int?
    public var contentType:String?

    public var dateString:String?

    public var from:String?
    public var host:String?
    public var maxForwards:Int?
    public var range:HTTPRequestHeader.Range?

    public var upgradeInsecureRequests:Bool = false
    public var xRequestedWith:HTTPRequestHeader.XRequestedWith?
    public var dnt:Bool?
    public var xHttpMethodOverride:(any HTTPRequestMethodProtocol)?
    public var secGPC:Bool = false

    public init(_ custom: [String:String] = [:]) {
        self.custom = custom
    }

    @inlinable
    public subscript(_ header: Key) -> Value? {
        get {
            return custom[header]
        }
        set {
            custom[header] = newValue
        }
    }

    @inlinable
    public func has(_ header: Key) -> Bool {
        return custom[header] != nil
    }

    @inlinable
    public mutating func add(_ value: String, header: String) {
        if let existingValue = custom[header] {
            custom[header] = existingValue + "," + value
        } else {
            custom[header] = value
        }
    }
}

// MARK: Accept
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func accept(_ mediaType: HTTPMediaType?) -> Self {
        if let mediaType {
            accept = "\(mediaType)"
        } else {
            accept = nil
        }
        return self
    }
}

// MARK: Accept-Charset
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func acceptCharset(_ charset: Charset?) -> Self {
        acceptCharset = charset
        return self
    }
}

// MARK: Accept-Encoding
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func acceptEncoding(_ encoding: HTTPRequestHeader.AcceptEncoding?) -> Self {
        acceptEncoding = encoding
        return self
    }
}

// MARK: Content-Length
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func contentLength(_ length: Int?) -> Self {
        contentLength = length
        return self
    }
}

// MARK: Content-Type
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func contentType(_ contentType: HTTPMediaType?) -> Self {
        if let contentType {
            self.contentType = "\(contentType)"
        } else {
            self.contentType = nil
        }
        return self
    }
}

// MARK: Date string
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func dateString(_ dateString: String?) -> Self {
        self.dateString = dateString
        return self
    }
}

// MARK: From
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func from(_ emailAddress: String?) -> Self {
        from = emailAddress
        return self
    }
}

// MARK: Host
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func host(_ host: String?) -> Self {
        self.host = host
        return self
    }
}

// MARK: Max-Forwards
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func maxForwards(_ maxForwards: Int?) -> Self {
        self.maxForwards = maxForwards
        return self
    }
}

// MARK: Range
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func range(_ range: HTTPRequestHeader.Range?) -> Self {
        self.range = range
        return self
    }
}

// MARK: X-Requested-With
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func xRequestedWith(_ with: HTTPRequestHeader.XRequestedWith?) -> Self {
        xRequestedWith = with
        return self
    }
}

// MARK: X-Http-Method-Override
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func xHttpMethodOverride(_ method: (some HTTPRequestMethodProtocol)?) -> Self {
        xHttpMethodOverride = method
        return self
    }
}

// MARK: Sec-GPC
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func secGPC(_ consented: Bool) -> Self {
        secGPC = consented
        return self
    }
}