//
//  HTTPRequestMethodProtocol.swift
//
//
//  Created by Evan Anderson on 3/1/25.
//

public protocol HTTPRequestMethodProtocol: Hashable, Sendable {
    var rawName: InlineArray<20, UInt8> { get }
}