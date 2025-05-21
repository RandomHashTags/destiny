
/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol: Sendable {
    associatedtype Key:Sendable
    associatedtype Value:Sendable

    @inlinable subscript(_ header: Key) -> Value? { get set }
    @inlinable subscript(_ header: Key) -> String? { get set }

    @inlinable subscript(_ header: String) -> Value? { get set }
    @inlinable subscript(_ header: String) -> String? { get set }

    /// Whether or not the target header exists.
    @inlinable func has(_ header: Key) -> Bool

    /// Whether or not the target header, as a `String`, exists.
    @inlinable func has(_ header: String) -> Bool
}