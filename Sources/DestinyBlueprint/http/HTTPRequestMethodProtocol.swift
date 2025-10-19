
public protocol HTTPRequestMethodProtocol: Sendable, ~Copyable {
    func rawNameString() -> String
}

extension String: HTTPRequestMethodProtocol { // TODO: use under a package trait
    @inlinable
    @inline(__always)
    public func rawNameString() -> String {
        self
    }
}