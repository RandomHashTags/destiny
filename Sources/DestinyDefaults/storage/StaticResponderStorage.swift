
import DestinyBlueprint

/// Default storage that handles static routes.
public struct StaticResponderStorage: StaticResponderStorageProtocol {

    @usableFromInline var macroExpansions:[DestinyRoutePathType:RouteResponses.MacroExpansion]
    @usableFromInline var macroExpansionsWithDateHeader:[DestinyRoutePathType:RouteResponses.MacroExpansionWithDateHeader]
    @usableFromInline var staticStrings:[DestinyRoutePathType:RouteResponses.StaticString]
    @usableFromInline var strings:[DestinyRoutePathType:RouteResponses.String]
    @usableFromInline var stringsWithDateHeader:[DestinyRoutePathType:RouteResponses.StringWithDateHeader]
    @usableFromInline var uint8Arrays:[DestinyRoutePathType:RouteResponses.UInt8Array]
    @usableFromInline var uint16Arrays:[DestinyRoutePathType:RouteResponses.UInt16Array]

    #if canImport(FoundationEssentials) || canImport(Foundation)
    @usableFromInline var foundationData:[DestinyRoutePathType:RouteResponses.FoundationData]
    #endif

    public init(
        macroExpansions: [DestinyRoutePathType:RouteResponses.MacroExpansion] = [:],
        macroExpansionsWithDateHeader: [DestinyRoutePathType:RouteResponses.MacroExpansionWithDateHeader] = [:],
        staticStrings: [DestinyRoutePathType:RouteResponses.StaticString] = [:],
        strings: [DestinyRoutePathType:RouteResponses.String] = [:],
        stringsWithDateHeader: [DestinyRoutePathType:RouteResponses.StringWithDateHeader] = [:],
        uint8Arrays: [DestinyRoutePathType:RouteResponses.UInt8Array] = [:],
        uint16Arrays: [DestinyRoutePathType:RouteResponses.UInt16Array] = [:]
    ) {
        self.macroExpansions = macroExpansions
        self.macroExpansionsWithDateHeader = macroExpansionsWithDateHeader
        self.staticStrings = staticStrings
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        foundationData = [:]
        #endif
    }

    public var debugDescription: String { // TODO: support foundationData
        """
        StaticResponderStorage(
            macroExpansions: \(macroExpansions.debugDescription),
            macroExpansionsWithDateHeader: \(macroExpansionsWithDateHeader.debugDescription),
            staticStrings: \(staticStrings.debugDescription),
            strings: \(strings.debugDescription),
            stringsWithDateHeader: \(stringsWithDateHeader.debugDescription),
            uint8Arrays: \(uint8Arrays.debugDescription),
            uint16Arrays: \(uint16Arrays.debugDescription)
        )
        """
    }

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        if let r = macroExpansions[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = macroExpansionsWithDateHeader[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = staticStrings[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = stringsWithDateHeader[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = strings[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = uint8Arrays[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else if let r = uint16Arrays[startLine] {
            try await router.respondStatically(socket: socket, responder: r)
        } else {
            #if canImport(FoundationEssentials) || canImport(Foundation)
            if let r = foundationData[startLine] {
                try await router.respondStatically(socket: socket, responder: r)
            } else {
                return false
            }
            #else
            return false
            #endif
        }
        return true
    }
}

// MARK: Register
extension StaticResponderStorage {
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: any RouteResponderProtocol) {
        if let responder = responder as? RouteResponses.MacroExpansion {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.MacroExpansionWithDateHeader {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.StaticString {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.String {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.StringWithDateHeader {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.UInt8Array {
            register(path: path, responder)
        } else if let responder = responder as? RouteResponses.UInt16Array {
            register(path: path, responder)
        }
    }

    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.MacroExpansion) {
        macroExpansions[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.MacroExpansionWithDateHeader) {
        macroExpansionsWithDateHeader[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.StaticString) {
        staticStrings[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.String) {
        strings[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.StringWithDateHeader) {
        stringsWithDateHeader[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.UInt8Array) {
        uint8Arrays[path] = responder
    }
    @inlinable
    public mutating func register(path: DestinyRoutePathType, _ responder: RouteResponses.UInt16Array) {
        uint16Arrays[path] = responder
    }
}