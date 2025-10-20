
/// Types conforming to this protocol can be used as a Response Body.
public protocol ResponseBodyProtocol: BufferWritable, ~Copyable {
    /// Total count of the body.
    var count: Int { get }

    /// The response body as a `String`.
    func string() -> String

    /// Whether or not the response body should apply the `date` header at compile time.
    var hasDateHeader: Bool { get }

    /// Whether or not the response body has a known content length at compile time.
    var hasContentLength: Bool { get }
}

// MARK: Defaults
extension ResponseBodyProtocol {
    #if Inlinable
    @inlinable
    #endif
    public var hasDateHeader: Bool {
        false
    }

    #if Inlinable
    @inlinable
    #endif
    public var hasContentLength: Bool {
        true
    }
}

extension ResponseBodyProtocol where Self: ~Copyable {
    #if Inlinable
    @inlinable
    #endif
    public var hasDateHeader: Bool {
        false
    }
    #if Inlinable
    @inlinable
    #endif
    public var hasContentLength: Bool {
        true
    }
}

// MARK: Default conformances
extension String: ResponseBodyProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        self
    }
}

extension StaticString: ResponseBodyProtocol {
    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        utf8CodeUnitCount
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        description
    }
}