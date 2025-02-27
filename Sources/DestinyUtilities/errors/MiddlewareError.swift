//
//  MiddlewareError.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

public struct MiddlewareError : DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}