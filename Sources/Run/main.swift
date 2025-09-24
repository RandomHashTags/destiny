
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

import DestinyBlueprint
import DestinyDefaults
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
var port:UInt16 = 8080
var backlog:Int32 = SOMAXCONN
if let v = processArg(key: "port") {
    port = UInt16(v) ?? port
}
if let v = processArg(key: "backlog") {
    backlog = Int32(v) ?? backlog
}
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
let application = Application(
    server: server,
    logger: Logger(label: "destiny.application")
)
HTTPDateFormat.load(logger: application.logger)
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
let application = Application(
    server: server
)
HTTPDateFormat.load()
#endif

application.run()

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
        return String(v[v.index(v.startIndex, offsetBy: 3 + key.count)...])
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
        let arguments = line.split(separator: " ")
        switch arguments.first {
        case "stop", "shutdown":
            await Application.shared.shutdown()
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

/*
let literalRoutes = [
    "GET /redirectto HTTP/1.1",
    "GET /stream HTTP/1.1",
    "GET /expressionMacro HTTP/1.1",
    "POST /post HTTP/1.1",
    "GET /bro?what=dude HTTP/1.1",
    "GET /html HTTP/1.1",
    "GET /html2 HTTP/2.0",
    "GET /json HTTP/1.1",
    "GET /txt HTTP/1.1",
    "GET /inlineBytes HTTP/1.1",
    "GET /bytes HTTP/1.1",
    "GET /bytes2 HTTP/1.1",
    "GET /bytes3 HTTP/1.1",
    "GET /plaintext HTTP/1.1",
    "GET /dynamicExpressionMacro HTTP/1.1",
    "GET /error2 HTTP/1.1",
    "GET /dynamic HTTP/1.1",
    "GET /asyncDynamic HTTP/1.1",
    "GET /dynamic2 HTTP/2.0"
]
let routes = literalRoutes.map({ PerfectHashableItem($0, SIMD64<UInt8>($0)) })
let perfectPositions = PerfectHashGenerator.findPerfectHashPositions(routes: routes, maxBytes: 8)

var perfectPositionsString = ""
for i in 0..<perfectPositions.count {
    perfectPositionsString.append("\(perfectPositions[i]), ")
}
print("main;perfectPositions=\(perfectPositionsString)")

let seeds:InlineArray<_, UInt64> = [
    0x9E3779B97F4A7C15,
    0xC6A4A7935D83A9C3,
    0x5555555555555555,
    0x1234567812345678,
    0x1F1F1F1F1F1F1F1F,
    0xFFFFFFFFFFFFFFFF,
    0x3141592653589793,
    0xDEADBEEFDEADBEEF,
    0xBADC0FFEBADC0FFE,
    0xCAFEBABECAFEBABE,
    0x0A0A0A0A0A0A0A0A,
    0x8000000080000000,
    0x1BADB0021BADB002,
    0xF00DF00DF00DF00D,
    0xBEAFBEAFBEAFBEAF,
    0x5A5A5A5A5A5A5A5A,
    0x8BADF00D8BADF00D,
    0xDEADD00DDEADD00D,
    0x1234ABCD1234ABCD,
    0x7F7F7F7F7F7F7F7F,
    0x2B2B2B2B2B2B2B2B,
    0x1E1E1E1E1E1E1E1E,
    0xA5A5A5A5A5A5A5A5,
    0x6C6C6C6C6C6C6C6C,
    0xF1F1F1F1F1F1F1F1,
    0x3C3C3C3C3C3C3C3C,
    0x8C8C8C8C8C8C8C8C,
    0xFEEDFACEFEEDFACE,
    0x1234123412341234,
    0x4567456745674567,
    0x9988776655443322,
    0xCDCDCDCDCDCDCDCD,
    0x1111111111111111,
    0x9999999999999999,
    0xDEEDDEEDDEEDDEED,
    0xFEEDBEEFFEEDBEEF,
    0xABCDEABCABCDEABC,
    0x5B5B5B5B5B5B5B5B,
    0x8001C8001C8001C8,
    0xD9D9D9D9D9D9D9D9,
    0x1112222333445555,
    0x9C9C9C9C9C9C9C9C,
    0xA8A8A8A8A8A8A8A8,
    0xE1E1E1E1E1E1E1E1,
    0x5D5D5D5D5D5D5D5D,
    0x4F4F4F4F4F4F4F4F,
    0xBABABABABABABABA,
    0x6E6E6E6E6E6E6E6E,
    0x7D7D7D7D7D7D7D7D,
    0x9F9F9F9F9F9F9F9F
]

for maxBytes in 1...8 {
    let perfectHash = PerfectHashGenerator(routes: routes, maxBytes: maxBytes)
    if let test = perfectHash.generatePerfectHash(seeds: seeds) {
        print("found perfect hash: maxBytes=\(maxBytes);seed=\(String(test.candidate.seed, radix: 16).uppercased());test=\(test)")
        break
    }
}*/