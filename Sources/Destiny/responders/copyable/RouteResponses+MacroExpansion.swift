
#if CopyableMacroExpansion

extension RouteResponses {
    public struct MacroExpansion: Sendable {
        public let bodyCount:String.UTF8View
        public let body:String.UTF8View
        public let value:StaticString

        public init(_ value: StaticString, body: String) {
            self.value = value
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
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    public func respond(
        provider: some SocketProvider,
        socket: some FileDescriptor
    ) throws(DestinyError) {
        var err:DestinyError? = nil
        value.withUTF8Buffer { valuePointer in
            bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                body.withContiguousStorageIfAvailable { bodyPointer in
                    let bodyCountSuffix:InlineArray<4, UInt8> = [.carriageReturn, .lineFeed, .carriageReturn, .lineFeed]
                    bodyCountSuffix.span.withUnsafeBufferPointer { bodyCountSuffixPointer in
                        do throws(DestinyError) {
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