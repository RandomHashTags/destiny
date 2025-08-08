
import DestinyBlueprint

/// Types conforming to this protocol can be used as...
public protocol ResponseBodyValueProtocol: BufferWritable, ~Copyable {
    var count: Int { get }

    func string() -> String

    //func temporaryAllocation<E: Error>(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws(E) -> Void) rethrows
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