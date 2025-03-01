//
//  HTTPRequestMethodProtocol.swift
//
//
//  Created by Evan Anderson on 3/1/25.
//

public protocol HTTPRequestMethodProtocol : Hashable, Sendable {
    var rawName : String { get }
}