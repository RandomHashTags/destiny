
#if Copyable && MutableRouter


/// Default mutable storage that handles case insensitive static routes.
public final class CaseInsensitiveStaticResponderStorage: @unchecked Sendable {
    public override func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine:SIMD64<UInt8>
        do throws(SocketError) {
            startLine = try request.startLineLowercased()
        } catch {
            throw .socketError(error)
        }

        #if CopyableMacroExpansion
        if let r = macroExpansions[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        #if CopyableMacroExpansionWithDateHeader
        if let r = macroExpansionsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        if let r = staticStrings[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }

        #if CopyableStaticStringWithDateHeader
        if let r = staticStringsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        #if CopyableStringWithDateHeader
        if let r = stringsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        #if StringRouteResponder
        if let r = strings[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        #if CopyableBytes
        if let r = bytes[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
            return true
        }
        #endif

        return false
    }
}

#if Protocols

// MARK: Conformances
extension CaseInsensitiveStaticResponderStorage: StaticResponderStorage {}

#endif

#endif