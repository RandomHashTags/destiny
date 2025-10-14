
#if canImport(Dispatch)
import Dispatch
#endif

#if canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#else
#error("not yet supported")
#endif

#if Logging
import Logging
#endif

/// Default storage that manages a group of services.
public final class DestinyServiceGroup: Sendable {
    public let services:[any DestinyServiceProtocol]

    #if Logging
    public let logger:Logger
    #endif

    private let onShutdown:@Sendable (Int32) -> Void

    nonisolated(unsafe) private var tasks:[Task<(), Never>] = []

    #if Logging
    public init(
        services: [any DestinyServiceProtocol],
        logger: Logger,
        onShutdown: @Sendable @escaping (Int32) -> Void = { _ in }
    ) {
        self.services = services
        self.logger = logger
        self.onShutdown = onShutdown
    }
    #else
    public init(
        services: [any DestinyServiceProtocol],
        onShutdown: @Sendable @escaping (Int32) -> Void = { _ in }
    ) {
        self.services = services
        self.onShutdown = onShutdown
    }
    #endif

    /// Runs all services until an interrupt is received.
    public func run() {
        tasks = []
        tasks.reserveCapacity(services.count)
        for i in services.indices {
            let service = services[i]
            let t = Task.detached {
                do throws(ServiceError) {
                    try await service.run()
                } catch {
                    #if Logging
                    self.logger.error("\(#function);error trying to run service=\(error)")
                    #endif
                }
                #if Logging
                self.logger.info("service exited")
                #endif
            }
            tasks.append(t)
        }
        // signalHandlers
        let _ = [
            SIGINT,
            SIGTERM,
        ].map { signalName in
            // https://github.com/swift-server/swift-service-lifecycle/blob/24c800fb494fbee6e42bc156dc94232dc08971af/Sources/UnixSignals/UnixSignalsSequence.swift#L80-L85
            #if canImport(Darwin)
                signal(signalName, SIG_IGN)
            #endif
            let signalSource = DispatchSource.makeSignalSource(signal: signalName, queue: .main)
            signalSource.setEventHandler {
                #if Logging
                self.logger.info("Got signal: \(signalName)")
                #endif
                Task {
                    await self._shutdown(signal: signalName)
                }
            }
            signalSource.resume()
            return signalSource
        }
        dispatchMain()
    }

    /// Shuts down all services.
    public func shutdown() async {
        #if Logging
        logger.info("Sending signal: SIGTERM")
        #endif
        await _shutdown(signal: SIGTERM)
    }
    private func _shutdown(signal: Int32) async {
        #if Logging
        logger.info("Received signal: SIGTERM")
        #endif
        await withTaskGroup { group in 
            for service in services {
                group.addTask {
                    do throws(ServiceError) {
                        try await service.shutdown()
                    } catch {
                        #if Logging
                        self.logger.error("error shutting down service=\(error)")
                        #endif
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