
/// Types conforming to this protocol can be used as...
public protocol ResponseBodyValueProtocol: Sendable {
    @inlinable
    var count: Int { get }

    @inlinable
    func string() -> String

    @inlinable
    func bytes() -> [UInt8]
}

extension StaticString: ResponseBodyValueProtocol {
    @inlinable
    public var count: Int {
        self.utf8CodeUnitCount
    }

    @inlinable
    public func string() -> String {
        description
    }

    @inlinable
    public func bytes() -> [UInt8] {
        Array(string().utf8)
    }

}
extension String: ResponseBodyValueProtocol {
    @inlinable
    public func string() -> String {
        self
    }

    @inlinable
    public func bytes() -> [UInt8] {
        Array(utf8)
    }
}