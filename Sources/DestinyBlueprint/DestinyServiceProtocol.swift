
#if canImport(Dispatch)
import Dispatch
#endif

#if canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#else
#error("not yet supported")
#endif

import Logging

// MARK: DestinyServiceProtocol
public protocol DestinyServiceProtocol: Sendable, ~Copyable {
    func run() async throws(ServiceError)

    /// Shuts down the service.
    func shutdown() async throws(ServiceError)
}

// MARK: DestinyServiceGroup
public final class DestinyServiceGroup: Sendable {
    public let services:[any DestinyServiceProtocol]
    public let logger:Logger
    private let onShutdown:@Sendable (Int32) -> Void

    nonisolated(unsafe) private var tasks:[Task<(), Never>] = []

    public init(
        services: [any DestinyServiceProtocol],
        logger: Logger,
        onShutdown: @Sendable @escaping (Int32) -> Void = { _ in }
    ) {
        self.services = services
        self.logger = logger
        self.onShutdown = onShutdown
    }

    public func run() {
        tasks = []
        tasks.reserveCapacity(services.count)
        for i in services.indices {
            let service = services[i]
            let t = Task.detached {
                do throws(ServiceError) {
                    try await service.run()
                } catch {
                    self.logger.error("\(#function);error trying to run service=\(error)")
                }
                self.logger.info("service exited")
            }
            tasks.append(t)
        }
        // signalHandlers
        let _ = [
            SIGINT, // ctrl+C in interactive mode
            SIGTERM, // docker container stop container_name
        ].map { signalName in
            // https://github.com/swift-server/swift-service-lifecycle/blob/24c800fb494fbee6e42bc156dc94232dc08971af/Sources/UnixSignals/UnixSignalsSequence.swift#L80-L85
            #if canImport(Darwin)
                signal(signalName, SIG_IGN)
            #endif
            let signalSource = DispatchSource.makeSignalSource(signal: signalName, queue: .main)
            signalSource.setEventHandler {
                self.logger.info("Got signal: \(signalName)")
                Task {
                    await self._shutdown(signal: signalName)
                }
            }
            signalSource.resume()
            return signalSource
        }
        dispatchMain()
    }

    public func shutdown() async {
        logger.info("Sending signal: SIGTERM")
        await _shutdown(signal: SIGTERM)
    }
    private func _shutdown(signal: Int32) async {
        logger.info("Received signal: SIGTERM")
        await withTaskGroup { group in 
            for service in services {
                group.addTask {
                    do throws(ServiceError) {
                        try await service.shutdown()
                    } catch {
                        self.logger.error("\(#function);error shutting down service=\(error)")
                    }
                }
            }
        }
        for task in tasks {
            task.cancel()
        }
        onShutdown(signal)
        exit(0)
    }
}