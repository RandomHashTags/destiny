//
//  CommandArgumentProtocol.swift
//
//
//  Created by Evan Anderson on 12/28/24.
//

/// A command argument.
public protocol CommandArgumentProtocol : Hashable {
    var slug : String { get }
    var aliases : Set<String> { get }

    func execute() async throws
}