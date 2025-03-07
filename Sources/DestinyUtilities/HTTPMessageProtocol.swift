//
//  HTTPMessageProtocol.swift
//
//
//  Created by Evan Anderson on 3/1/25.
//

public protocol HTTPMessageProtocol : CustomDebugStringConvertible, Sendable {
    associatedtype ConcreteHTTPResponseHeaders:HTTPResponseHeadersProtocol
    associatedtype ConcreteHTTPCookie:HTTPCookieProtocol

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable func string(escapeLineBreak: Bool) throws -> String
}