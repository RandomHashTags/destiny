
import DestinyBlueprint

/// Default mutable storage that handles static routes.
public struct StaticResponderStorage: StaticResponderStorageProtocol {

    @usableFromInline var macroExpansions:[DestinyRoutePathType:RouteResponses.MacroExpansion]
    @usableFromInline var macroExpansionsWithDateHeader:[DestinyRoutePathType:MacroExpansionWithDateHeader]
    @usableFromInline var staticStrings:[DestinyRoutePathType:StaticString]
    @usableFromInline var staticStringsWithDateHeader:[DestinyRoutePathType:StaticStringWithDateHeader]
    @usableFromInline var strings:[DestinyRoutePathType:String]
    @usableFromInline var stringsWithDateHeader:[DestinyRoutePathType:StringWithDateHeader]
    @usableFromInline var uint8Arrays:[DestinyRoutePathType:ResponseBody.Bytes]

    public init(
        macroExpansions: [DestinyRoutePathType:RouteResponses.MacroExpansion] = [:],
        macroExpansionsWithDateHeader: [DestinyRoutePathType:MacroExpansionWithDateHeader] = [:],
        staticStrings: [DestinyRoutePathType:StaticString] = [:],
        staticStringsWithDateHeader: [DestinyRoutePathType:StaticStringWithDateHeader] = [:],
        strings: [DestinyRoutePathType:String] = [:],
        stringsWithDateHeader: [DestinyRoutePathType:StringWithDateHeader] = [:],
        uint8Arrays: [DestinyRoutePathType:ResponseBody.Bytes] = [:]
    ) {
        self.macroExpansions = macroExpansions
        self.macroExpansionsWithDateHeader = macroExpansionsWithDateHeader
        self.staticStrings = staticStrings
        self.staticStringsWithDateHeader = staticStringsWithDateHeader
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.uint8Arrays = uint8Arrays
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
        } else if let r = uint8Arrays[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else {
            return false
        }
        return true
    }
}

// MARK: Register
extension StaticResponderStorage {
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: some RouteResponderProtocol) {
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
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.MacroExpansion) {
        macroExpansions[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: MacroExpansionWithDateHeader) {
        macroExpansionsWithDateHeader[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: StaticString) {
        staticStrings[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: StaticStringWithDateHeader) {
        staticStringsWithDateHeader[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: String) {
        strings[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: StringWithDateHeader) {
        stringsWithDateHeader[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: ResponseBody.Bytes) {
        uint8Arrays[path] = responder
    }
}