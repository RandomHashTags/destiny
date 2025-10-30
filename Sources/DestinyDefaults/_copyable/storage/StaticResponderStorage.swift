
#if StaticResponderStorage

import DestinyEmbedded

/// Default mutable storage that handles static routes.
/// 
/// - Warning: Is case-sensitive by default.
public class StaticResponderStorage: @unchecked Sendable {

    #if CopyableMacroExpansion
    @usableFromInline var macroExpansions:[SIMD64<UInt8>:RouteResponses.MacroExpansion]
    #endif

    #if CopyableMacroExpansionWithDateHeader
    @usableFromInline var macroExpansionsWithDateHeader:[SIMD64<UInt8>:MacroExpansionWithDateHeader]
    #endif

    @usableFromInline var staticStrings:[SIMD64<UInt8>:StaticString]

    #if CopyableStaticStringWithDateHeader
    @usableFromInline var staticStringsWithDateHeader:[SIMD64<UInt8>:StaticStringWithDateHeader]
    #endif

    #if StringRouteResponder
    @usableFromInline var strings:[SIMD64<UInt8>:String]
    #endif

    #if CopyableStringWithDateHeader
    @usableFromInline var stringsWithDateHeader:[SIMD64<UInt8>:StringWithDateHeader]
    #endif

    #if CopyableBytes
    @usableFromInline var bytes:[SIMD64<UInt8>:Bytes]
    #endif

    public init() {
        #if CopyableMacroExpansion
        macroExpansions = [:]
        #endif

        #if CopyableMacroExpansionWithDateHeader
        macroExpansionsWithDateHeader = [:]
        #endif

        staticStrings = [:]

        #if CopyableStaticStringWithDateHeader
        staticStringsWithDateHeader = [:]
        #endif

        #if StringRouteResponder
        strings = [:]
        #endif

        #if CopyableStringWithDateHeader
        stringsWithDateHeader = [:]
        #endif

        #if CopyableBytes
        bytes = [:]
        #endif
    }

    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine:SIMD64<UInt8>
        do throws(SocketError) {
            startLine = try request.startLine()
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

// MARK: Register
extension StaticResponderStorage {
    /// Registers a static route responder to the given route path.
    #if Inlinable
    @inlinable
    #endif
    public func register(
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    ) {
        #if CopyableMacroExpansion
        if let responder = responder as? RouteResponses.MacroExpansion {
            register(path: path, responder)
            return
        }
        #endif

        #if CopyableMacroExpansionWithDateHeader
        if let responder = responder as? MacroExpansionWithDateHeader {
            register(path: path, responder)
            return
        }
        #endif

        if let responder = responder as? StaticString {
            register(path: path, responder)
            return
        }

        #if CopyableStaticStringWithDateHeader
        if let responder = responder as? StaticStringWithDateHeader {
            register(path: path, responder)
            return
        }
        #endif

        #if StringRouteResponder
        if let responder = responder as? String {
            register(path: path, responder)
            return
        }
        #endif

        #if CopyableStringWithDateHeader
        if let responder = responder as? StringWithDateHeader {
            register(path: path, responder)
            return
        }
        #endif

        #if CopyableBytes
        if let responder = responder as? Bytes {
            register(path: path, responder)
            return
        }
        #endif
    }

    #if CopyableMacroExpansion
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: RouteResponses.MacroExpansion) {
        macroExpansions[path] = responder
    }
    #endif

    #if CopyableMacroExpansionWithDateHeader
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: MacroExpansionWithDateHeader) {
        macroExpansionsWithDateHeader[path] = responder
    }
    #endif

    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: StaticString) {
        staticStrings[path] = responder
    }

    #if CopyableStaticStringWithDateHeader
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: StaticStringWithDateHeader) {
        staticStringsWithDateHeader[path] = responder
    }
    #endif

    #if StringRouteResponder
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: String) {
        strings[path] = responder
    }
    #endif

    #if CopyableStringWithDateHeader
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: StringWithDateHeader) {
        stringsWithDateHeader[path] = responder
    }
    #endif

    #if CopyableBytes
    #if Inlinable
    @inlinable
    #endif
    public func register(path: SIMD64<UInt8>, _ responder: Bytes) {
        bytes[path] = responder
    }
    #endif
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension StaticResponderStorage: ResponderStorageProtocol {}

#endif

#endif