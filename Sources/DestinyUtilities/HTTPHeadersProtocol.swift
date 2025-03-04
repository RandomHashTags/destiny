//
//  HTTPHeadersProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol : CustomDebugStringConvertible, Sendable {
    associatedtype Key : Sendable
    associatedtype Value : Sendable

    init()

    @inlinable subscript(_ header: Key) -> Value? { get set }
    @inlinable subscript(_ header: Key) -> String? { get set }
    @inlinable subscript(_ header: Key, default defaultValue: @autoclosure () -> Key) -> Value { get set }

    @inlinable subscript(_ header: String) -> Value? { get set }
    @inlinable subscript(_ header: String) -> String? { get set }
    @inlinable subscript(_ header: String, default defaultValue: @autoclosure () -> String) -> String { get set }

    /// Whether or not the target header exists.
    @inlinable func has(_ header: Key) -> Bool

    /// Whether or not the target header, as a `String`, exists.
    @inlinable func has(_ header: String) -> Bool

    @inlinable mutating func merge(_ headers: Self)

    @inlinable func iterate(yield: (Key, Value) -> Void)
}