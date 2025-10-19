
public protocol HTTPRequestMethodProtocol: Sendable, ~Copyable {
    func rawNameString() -> String
}

#if StringRequestMethod
extension String: HTTPRequestMethodProtocol {
    @inlinable
    @inline(__always)
    public func rawNameString() -> String {
        self
    }
}
#endif