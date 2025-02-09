//
//  StopCommand.swift
//
//
//  Created by Evan Anderson on 12/31/24.
//

#if canImport(ArgumentParser)
import ArgumentParser
#endif

public struct StopCommand : AsyncParsableCommand {
    public static let configuration:CommandConfiguration = CommandConfiguration(commandName: "stop", aliases: ["shutdown"])

    public init() {
    }

    public func run() async throws {
        try await Application.shared.shutdown()
    }
}