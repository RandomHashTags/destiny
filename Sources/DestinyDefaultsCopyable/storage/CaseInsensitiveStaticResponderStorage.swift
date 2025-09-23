
#if MutableRouter

import DestinyBlueprint
import DestinyDefaults

/// Default mutable storage that handles case insensitive static routes.
public final class CaseInsensitiveStaticResponderStorage: StaticResponderStorage, @unchecked Sendable {
    #if Inlinable
    @inlinable
    #endif
    public override func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine:SIMD64<UInt8>
        do throws(SocketError) {
            startLine = try request.startLineLowercased()
        } catch {
            throw .socketError(error)
        }
        if let r = macroExpansions[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = macroExpansionsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = staticStrings[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = staticStringsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = stringsWithDateHeader[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = strings[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = bytes[startLine] {
            try router.respond(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else {
            return false
        }
        return true
    }
}

#endif