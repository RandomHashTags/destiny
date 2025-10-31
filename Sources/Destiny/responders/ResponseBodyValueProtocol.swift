

/// Types conforming to this protocol can be used as a response body's value. Mainly used for convenience for macro usage.
public protocol ResponseBodyValueProtocol: BufferWritable, ~Copyable {
    var count: Int { get }

    func string() -> String
}

// MARK: Default conformances
extension String: ResponseBodyValueProtocol {}
extension StaticString: ResponseBodyValueProtocol {}