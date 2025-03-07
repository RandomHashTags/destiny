//
//  HTTPHeadersProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol : CustomDebugStringConvertible, Sendable {
    var custom : [String:String] { get }

    init()

    @inlinable subscript(_ header: String) -> String? { get set }
    @inlinable subscript(_ header: String, default defaultValue: @autoclosure () -> String) -> String { get set }

    /// Whether or not the target header.
    @inlinable func has(_ header: String) -> Bool

    @inlinable func iterate(yield: (String, String) -> Void)
}