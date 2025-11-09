
#if canImport(Dispatch)
import Dispatch
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(SwiftGlibc)
import SwiftGlibc
#endif

import Destiny
import TestRouter

#if Logging
import Logging

LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    #if DEBUG
    handler.logLevel = .debug
    #else
    handler.logLevel = .error
    #endif
    return handler
}
#endif

// MARK: Config
let address = processArg(key: "hostname")
let port:UInt16 = 8080
let backlog:Int32 = SOMAXCONN
let reuseAddress = processArg(key: "reuseaddress")?.elementsEqual("true") ?? true
let reusePort = processArg(key: "reuseport")?.elementsEqual("true") ?? true
let noTCPDelay = processArg(key: "tcpnodelay")?.elementsEqual("true") ?? true

#if Logging
let server = NonCopyableHTTPServer<TestRouter.DeclaredRouter.CompiledHTTPRouter, HTTPSocket>(
    address: address,
    port: port,
    backlog: backlog,
    reuseAddress: reuseAddress,
    reusePort: reusePort,
    noTCPDelay: noTCPDelay,
    router: TestRouter.DeclaredRouter.router,
    logger: Logger(label: "destiny.http.server"),
    onLoad: serverOnLoad
)
HTTPDateFormat.load(logger: Logger(label: "destiny.http.dateformat"))
#else
let server = NonCopyableHTTPServer<TestRouter.DeclaredRouter.CompiledHTTPRouter, HTTPSocket>(
    address: address,
    port: port,
    backlog: backlog,
    reuseAddress: reuseAddress,
    reusePort: reusePort,
    noTCPDelay: noTCPDelay,
    router: TestRouter.DeclaredRouter.router,
    onLoad: serverOnLoad
)
HTTPDateFormat.load()
#endif

try await server.run()

// MARK: On load
@Sendable
func serverOnLoad() {
    #if canImport(Dispatch)
    Task {
        await processCommand()
    }
    #else
    #warning("commands aren't supported")
    #endif
}
@inlinable
func processArg(key: String) -> String? {
    if let v = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--" + key + "=") }) {
        return String(v[v.index(v.startIndex, offsetBy: 3 + key.utf8Span.count)...])
    }
    return nil
}
private func readCommand() async -> String? {
    return await withCheckedContinuation { continuation in
        #if canImport(Dispatch)
        DispatchQueue.global().async {
            continuation.resume(returning: readLine())
        }
        #else
        continuation.resume(returning: nil)
        #endif
    }
}
func processCommand() async {
    if let line = await readCommand() {
        let cmdEndIndex = line.firstIndex(of: " ") ?? line.endIndex
        let cmd = line[line.startIndex..<cmdEndIndex]
        switch cmd {
        case "stop", "shutdown":
            server.shutdown()
            return
        default:
            break
        }
    }
    guard !Task.isCancelled else { return }
    Task {
        await processCommand()
    }
}