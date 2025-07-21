
/// Types conforming to this protocol can be used as...
public protocol ResponseBodyValueProtocol: Sendable {
    @inlinable
    var count: Int { get }

    @inlinable
    func string() -> String
}

// MARK: Default conformances
extension String: ResponseBodyValueProtocol {
    @inlinable
    public func string() -> String {
        self
    }
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
}