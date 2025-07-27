
public protocol ResponseBodyProtocol: BufferWritable, ~Copyable {
    @inlinable
    var count: Int { get }

    @inlinable
    func string() -> String

    @inlinable
    var hasDateHeader: Bool { get }

    @inlinable
    var hasContentLength: Bool { get }

    @inlinable
    func customInitializer(bodyString: String) -> String?
}

extension ResponseBodyProtocol {
    @inlinable public var hasDateHeader: Bool { false }
    @inlinable public var hasContentLength: Bool { true }
    @inlinable public func customInitializer(bodyString: String) -> String? { nil }
}

// MARK: Default conformances
extension String: ResponseBodyProtocol {
    @inlinable
    public var count: Int {
        utf8.count
    }
    
    @inlinable
    public func string() -> String {
        self
    }
}

extension StaticString: ResponseBodyProtocol {
    @inlinable
    public var count: Int {
        utf8CodeUnitCount
    }
    
    @inlinable
    public func string() -> String {
        description
    }
}