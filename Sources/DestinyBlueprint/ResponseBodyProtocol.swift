
public protocol ResponseBodyProtocol: BufferWritable, ~Copyable {
    var count: Int { get }

    func string() -> String

    var hasDateHeader: Bool { get }

    var hasContentLength: Bool { get }
}

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