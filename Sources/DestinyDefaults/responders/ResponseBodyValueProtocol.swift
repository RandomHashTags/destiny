
import DestinyEmbedded

/// Types conforming to this protocol can be used as a response body's value. Mainly used for convenience for macro usage.
public protocol ResponseBodyValueProtocol: BufferWritable, ~Copyable {
    var count: Int { get }

    func string() -> String
}

// MARK: Default conformances
extension String: ResponseBodyValueProtocol {
    public func string() -> String {
        self
    }
}

extension StaticString: ResponseBodyValueProtocol {
    public var count: Int {
        self.utf8CodeUnitCount
    }

    public func string() -> String {
        description
    }
}