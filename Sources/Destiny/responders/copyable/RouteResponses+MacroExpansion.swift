
#if CopyableMacroExpansion

#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

extension RouteResponses {
    public struct MacroExpansion: Sendable {
        public static let bodyCountSuffix:iovec = {
            let ss:StaticString = "\r\n\r\n"
            return .init(iov_base: .init(mutating: ss.utf8Start), iov_len: ss.utf8CodeUnitCount)
        }()

        public let bodyCount:String.UTF8View
        public let body:String.UTF8View
        public let value:iovec

        public init(_ value: StaticString, body: String) {
            self.value = .init(iov_base: .init(mutating: value.utf8Start), iov_len: value.utf8CodeUnitCount)
            bodyCount = String(body.utf8Span.count).utf8
            self.body = body.utf8
        }
    }
}

// MARK: Respond
extension RouteResponses.MacroExpansion {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    public func respond(
        provider: some SocketProvider,
        socket: some FileDescriptor
    ) throws(DestinyError) {
        var err:DestinyError? = nil
        bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
            body.withContiguousStorageIfAvailable { bodyPointer in
                do throws(DestinyError) {
                    try socket.writeBuffers4(
                        value,
                        bodyCountPointer,
                        Self.bodyCountSuffix,
                        bodyPointer
                    )
                } catch {
                    err = error
                }
            }
        }
        socket.flush(provider: provider)
        if let err {
            throw err
        }
    }
}

#if Protocols

// MARK: Conformances
extension RouteResponses.MacroExpansion: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try respond(provider: provider, socket: request.fileDescriptor)
    }
}

#endif

#endif