
#if Copyable && MutableRouter

/// Default mutable storage that handles case insensitive static routes.
public final class CaseInsensitiveStaticResponderStorage: @unchecked Sendable {
    public override func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest
    ) throws(DestinyError) -> Bool {
        let startLine = try request.startLineLowercased()

        #if CopyableMacroExpansion
        if let r = macroExpansions[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }
        #endif

        #if CopyableMacroExpansionWithDateHeader
        if let r = macroExpansionsWithDateHeader[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }
        #endif

        if let r = staticStrings[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }

        #if CopyableStaticStringWithDateHeader
        if let r = staticStringsWithDateHeader[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }
        #endif

        #if CopyableStringWithDateHeader
        if let r = stringsWithDateHeader[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }
        #endif

        #if StringRouteResponder
        if let r = strings[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
            return true
        }
        #endif

        #if CopyableBytes
        if let r = bytes[startLine] {
            try router.respond(provider: provider, request: &request, responder: r)
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