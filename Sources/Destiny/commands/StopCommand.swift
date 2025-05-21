
import ArgumentParser

public struct StopCommand: AsyncParsableCommand {
    public static let configuration:CommandConfiguration = CommandConfiguration(commandName: "stop", aliases: ["shutdown"])

    public init() {
    }

    public func run() async throws {
        try await Application.shared.shutdown()
    }
}