
import DestinyBlueprint

/// Default mutable storage that handles static routes.
public final class StaticResponderStorage: MutableStaticResponderStorageProtocol, @unchecked Sendable {

    @usableFromInline var macroExpansions:[DestinyRoutePathType:RouteResponses.MacroExpansion]
    @usableFromInline var macroExpansionsWithDateHeader:[DestinyRoutePathType:MacroExpansionWithDateHeader]
    @usableFromInline var staticStrings:[DestinyRoutePathType:StaticString]
    @usableFromInline var staticStringsWithDateHeader:[DestinyRoutePathType:StaticStringWithDateHeader]
    @usableFromInline var strings:[DestinyRoutePathType:String]
    @usableFromInline var stringsWithDateHeader:[DestinyRoutePathType:StringWithDateHeader]
    @usableFromInline var bytes:[DestinyRoutePathType:ResponseBody.Bytes]

    public init(
        macroExpansions: [DestinyRoutePathType:RouteResponses.MacroExpansion] = [:],
        macroExpansionsWithDateHeader: [DestinyRoutePathType:MacroExpansionWithDateHeader] = [:],
        staticStrings: [DestinyRoutePathType:StaticString] = [:],
        staticStringsWithDateHeader: [DestinyRoutePathType:StaticStringWithDateHeader] = [:],
        strings: [DestinyRoutePathType:String] = [:],
        stringsWithDateHeader: [DestinyRoutePathType:StringWithDateHeader] = [:],
        bytes: [DestinyRoutePathType:ResponseBody.Bytes] = [:]
    ) {
        self.macroExpansions = macroExpansions
        self.macroExpansionsWithDateHeader = macroExpansionsWithDateHeader
        self.staticStrings = staticStrings
        self.staticStringsWithDateHeader = staticStringsWithDateHeader
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.bytes = bytes
    }

    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        startLine: DestinyRoutePathType
    ) async throws(ResponderError) -> Bool {
        if let r = macroExpansions[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = macroExpansionsWithDateHeader[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = staticStrings[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = staticStringsWithDateHeader[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = stringsWithDateHeader[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = strings[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = bytes[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else {
            return false
        }
        return true
    }
}

// MARK: Debug description
extension StaticResponderStorage {
    public var debugDescription: String {
        """
        StaticResponderStorage(
            macroExpansions: \(macroExpansions),
            macroExpansionsWithDateHeader: \(macroExpansionsWithDateHeader),
            staticStrings: \(staticStrings),
            staticStringsWithDateHeader: \(staticStringsWithDateHeader),
            strings: \(strings),
            stringsWithDateHeader: \(stringsWithDateHeader),
            bytes: \(bytes)
        )
        """
    }
}

// MARK: Register
extension StaticResponderStorage {
    @inlinable
    public func register(
        path: DestinyRoutePathType,
        _ responder: some StaticRouteResponderProtocol
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
    public func register(path: DestinyRoutePathType, _ responder: RouteResponses.MacroExpansion) {
        macroExpansions[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: MacroExpansionWithDateHeader) {
        macroExpansionsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: StaticString) {
        staticStrings[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: StaticStringWithDateHeader) {
        staticStringsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: String) {
        strings[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: StringWithDateHeader) {
        stringsWithDateHeader[path] = responder
    }
    @inlinable
    public func register(path: DestinyRoutePathType, _ responder: ResponseBody.Bytes) {
        bytes[path] = responder
    }
}