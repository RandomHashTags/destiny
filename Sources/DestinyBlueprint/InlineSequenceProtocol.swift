//
//  InlineSequenceProtocol.swift
//
//
//  Created by Evan Anderson on 5/8/25.
//

public protocol InlineSequenceProtocol: Sendable, ~Copyable {
    associatedtype Element
}