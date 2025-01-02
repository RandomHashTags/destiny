//
//  BootCommands.swift
//
//
//  Created by Evan Anderson on 12/31/24.
//

import ArgumentParser

/// Defines what boot options can be used for a server.
public struct BootCommands : ParsableCommand {
    @Option(
        name: .init([
            .customLong("hostname"),
            .customShort("h")
        ]),
        help: "Hostname the server uses."
    )
    public var hostname:String?
    
    @Option(
        name: .init([
            .customLong("port"),
            .customShort("p")
        ]),
        help: "Port to run the server on."
    )
    public var port:UInt16?

    @Option(
        name: .init([
            .customLong("backlog"),
            .customShort("b")
        ]),
        help: "Maximum amount of pending connections the server can have."
    )
    public var backlog:Int32?

    public init() {
    }
}