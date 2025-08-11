
import DestinyBlueprint

/// Default mutable storage that handles case insensitive static routes.
public final class CaseInsensitiveStaticResponderStorage: MutableStaticResponderStorageProtocol, @unchecked Sendable {

    @usableFromInline var macroExpansions:[SIMD64<UInt8>:RouteResponses.MacroExpansion]
    @usableFromInline var macroExpansionsWithDateHeader:[SIMD64<UInt8>:MacroExpansionWithDateHeader]
    @usableFromInline var staticStrings:[SIMD64<UInt8>:StaticString]
    @usableFromInline var staticStringsWithDateHeader:[SIMD64<UInt8>:StaticStringWithDateHeader]
    @usableFromInline var strings:[SIMD64<UInt8>:String]
    @usableFromInline var stringsWithDateHeader:[SIMD64<UInt8>:StringWithDateHeader]
    @usableFromInline var bytes:[SIMD64<UInt8>:ResponseBody.Bytes]

    public init(
        macroExpansions: [SIMD64<UInt8>:RouteResponses.MacroExpansion] = [:],
        macroExpansionsWithDateHeader: [SIMD64<UInt8>:MacroExpansionWithDateHeader] = [:],
        staticStrings: [SIMD64<UInt8>:StaticString] = [:],
        staticStringsWithDateHeader: [SIMD64<UInt8>:StaticStringWithDateHeader] = [:],
        strings: [SIMD64<UInt8>:String] = [:],
        stringsWithDateHeader: [SIMD64<UInt8>:StringWithDateHeader] = [:],
        bytes: [SIMD64<UInt8>:ResponseBody.Bytes] = [:]
    ) {
        self.macroExpansions = macroExpansions
        self.macroExpansionsWithDateHeader = macroExpansionsWithDateHeader
        self.staticStrings = staticStrings
        self.staticStringsWithDateHeader = staticStringsWithDateHeader
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.bytes = bytes
    }
}

// AMRK: Respond
extension CaseInsensitiveStaticResponderStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine = request.startLineLowercased()
        if let r = macroExpansions[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = macroExpansionsWithDateHeader[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = staticStrings[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = staticStringsWithDateHeader[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = stringsWithDateHeader[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = strings[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else if let r = bytes[startLine] {
            try router.respondStatically(socket: socket, request: &request, responder: r, completionHandler: completionHandler)
        } else {
            return false
        }
        return true
    }
}

// MARK: Register
extension CaseInsensitiveStaticResponderStorage {
    @inlinable
    public func register(
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    ) {
        if let responder = responder as? RouteResponses.MacroExpansion {
            register(path: path, responder)
        } else if let responder = responder as? MacroExpansionWithDateHeader {
            register(path: path, responder)
        } else if let responder = responder as? StaticString {
            register(path: path, responder)
        } else if let responder = responder as? StaticStringWithDateHeader {
            register(path: path, responder)
        } else if let responder = responder as? String {
            register(path: path, responder)
        } else if let responder = responder as? StringWithDateHeader {
            register(path: path, responder)
        } else if let responder = responder as? ResponseBody.Bytes {
            register(path: path, responder)
        }
    }

    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: RouteResponses.MacroExpansion) {
        macroExpansions[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: MacroExpansionWithDateHeader) {
        macroExpansionsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: StaticString) {
        staticStrings[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: StaticStringWithDateHeader) {
        staticStringsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: String) {
        strings[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: StringWithDateHeader) {
        stringsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: SIMD64<UInt8>, _ responder: ResponseBody.Bytes) {
        bytes[path] = responder
    }
}