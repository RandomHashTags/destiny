
#if CopyableMacroExpansion

import DestinyEmbedded

extension RouteResponses {
    public struct MacroExpansion: Sendable {
        public let value:StaticString
        public let bodyCount:String.UTF8View
        public let body:String.UTF8View

        public init(_ value: StaticString, body: String) {
            self.value = value
            bodyCount = String(body.utf8Span.count).utf8
            self.body = body.utf8
        }
    }
}

// MARK: Respond
extension RouteResponses.MacroExpansion {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        socket: some FileDescriptor,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        value.withUTF8Buffer { valuePointer in
            bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                body.withContiguousStorageIfAvailable { bodyPointer in
                    let bodyCountSuffix:InlineArray<4, UInt8> = [.carriageReturn, .lineFeed, .carriageReturn, .lineFeed]
                    bodyCountSuffix.span.withUnsafeBufferPointer { bodyCountSuffixPointer in
                        do throws(SocketError) {
                            try socket.writeBuffers4(
                                valuePointer,
                                bodyCountPointer,
                                bodyCountSuffixPointer,
                                bodyPointer
                            )
                        } catch {
                            err = error
                        }
                    }
                }
            }
        }
        if let err {
            throw .socketError(err)
        }
        completionHandler()
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension RouteResponses.MacroExpansion: StaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif