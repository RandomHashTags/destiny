
/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol: Sequence, Sendable where Element == (key: String, value: String) {
    associatedtype Key:Sendable
    associatedtype Value:Sendable

    subscript(_ header: Key) -> Value? { get set }
    subscript(_ header: Key) -> String? { get set }

    subscript(_ header: String) -> Value? { get set }
    subscript(_ header: String) -> String? { get set }

    /// Whether or not the given header exists.
    func has(_ header: Key) -> Bool

    /// Whether or not the given header, as a `String`, exists.
    func has(_ header: String) -> Bool
}