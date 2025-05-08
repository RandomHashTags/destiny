//
//  DynamicResponseProtocol.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol: Sendable, CustomDebugStringConvertible {
    /// Timestamps when request events happen.
    var timestamps: DynamicRequestTimestamps { get set }

    var message: any HTTPMessageProtocol { get set }

    /// The parameters associated with the route. Updated upon requests.
    //var parameters: [String] { get set }

    @inlinable
    func parameter(at index: Int) -> String

    @inlinable
    mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>)
}