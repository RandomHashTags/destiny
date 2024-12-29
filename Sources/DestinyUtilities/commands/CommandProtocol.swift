//
//  CommandProtocol.swift
//
//
//  Created by Evan Anderson on 12/28/24.
//

/// Commands that can execute in the terminal while the server is booting or running.
public protocol CommandProtocol {

    var slug : String { get }
    var aliases : Set<String> { get }
    var arguments : [any CommandArgumentProtocol] { get }

    func execute() async throws
}