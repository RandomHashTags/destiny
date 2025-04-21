//
//  HTTPMessageProtocol.swift
//
//
//  Created by Evan Anderson on 4/19/25.
//

public protocol HTTPMessageProtocol : CustomDebugStringConvertible, Sendable {

    @inlinable var version : HTTPVersion { get set }

    @inlinable var status : HTTPResponseStatus.Code { get set }

    //@inlinable func response() -> InlineArrayProtocol // TODO: need to wait to use ValueGenerics

    @inlinable mutating func assignResult(_ string: String)

    @inlinable mutating func setHeader(key: String, value: String)

    @inlinable mutating func appendCookie<T: HTTPCookieProtocol>(_ cookie: T)

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable
    func string(escapeLineBreak: Bool) throws -> String
}