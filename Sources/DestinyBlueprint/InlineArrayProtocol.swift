//
//  InlineArrayProtocol.swift
//
//
//  Created by Evan Anderson on 4/20/25.
//

public protocol InlineArrayProtocol : Sendable, ~Copyable {
    var count : Int { get }
    var indices : Range<Int> { get }
}

extension InlineArray : InlineArrayProtocol {
}