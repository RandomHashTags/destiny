//
//  HTTPHeadersProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol : Sendable {
    associatedtype Key : Sendable
    associatedtype Value : Sendable

    @inlinable subscript(_ header: Key) -> Value? { get set }
    @inlinable subscript(_ header: Key) -> String? { get set }

    @inlinable subscript(_ header: String) -> Value? { get set }
    @inlinable subscript(_ header: String) -> String? { get set }

    @inlinable func has(_ header: Key) -> Bool
    @inlinable func has(_ header: String) -> Bool
}