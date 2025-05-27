
import DestinyBlueprint

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage<
        let macroExpansionsCount: Int,
        let macroExpansionsWithDateHeaderCount: Int,
        let staticStringsCount: Int,
        let stringsCount: Int,
        let stringsWithDateHeaderCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: StaticResponderStorageProtocol {

    public let macroExpansions:InlineArray<macroExpansionsCount, Route<RouteResponses.MacroExpansion>>
    public let macroExpansionsWithDateHeader:InlineArray<macroExpansionsWithDateHeaderCount, Route<RouteResponses.MacroExpansionWithDateHeader>>
    public let staticStrings:InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>
    public let strings:InlineArray<stringsCount, Route<RouteResponses.String>>
    public let stringsWithDateHeader:InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>
    public let uint8Arrays:InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineVLArray<Route<RouteResponses.FoundationData>>
    #endif

    public init(
        macroExpansions: InlineArray<macroExpansionsCount, Route<RouteResponses.MacroExpansion>>,
        macroExpansionsWithDateHeader: InlineArray<macroExpansionsWithDateHeaderCount, Route<RouteResponses.MacroExpansionWithDateHeader>>,
        staticStrings: InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>,
        strings: InlineArray<stringsCount, Route<RouteResponses.String>>,
        stringsWithDateHeader: InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>,
        uint8Arrays: InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>,
        uint16Arrays: InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>
    ) {
        self.macroExpansions = macroExpansions
        self.macroExpansionsWithDateHeader = macroExpansionsWithDateHeader
        self.staticStrings = staticStrings
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        //foundationData = []
        #endif
    }

    func debugDescription<let count: Int, T: StaticRouteResponderProtocol>(for responders: InlineArray<count, Route<T>>) -> String {
        var s = "[]"
        if !responders.isEmpty {
            var values = [String]()
            values.reserveCapacity(responders.count)
            for i in responders.indices {
                values.append(responders[i].debugDescription)
            }
            s = "[" + values.joined(separator: ",\n") + "\n]"
        }
        return s
    }

    public var debugDescription: String {
        """
        CompiledStaticResponderStorage(
            macroExpansions: \(debugDescription(for: macroExpansions)),
            macroExpansionsWithDateHeader: \(debugDescription(for: macroExpansionsWithDateHeader)),
            staticStrings: \(debugDescription(for: staticStrings)),
            strings: \(debugDescription(for: strings)),
            stringsWithDateHeader: \(debugDescription(for: stringsWithDateHeader)),
            uint8Arrays: \(debugDescription(for: uint8Arrays)),
            uint16Arrays: \(debugDescription(for: uint16Arrays))
        )
        """
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        if try await respondStatically(router, socket, startLine, macroExpansions) {
            return true
        } else if try await respondStatically(router, socket, startLine, macroExpansionsWithDateHeader) {
            return true
        } else if try await respondStatically(router, socket, startLine, staticStrings) {
            return true
        } else if try await respondStatically(router, socket, startLine, strings) {
            return true
        } else if try await respondStatically(router, socket, startLine, stringsWithDateHeader) {
            return true
        } else if try await respondStatically(router, socket, startLine, uint8Arrays) {
            return true
        } else if try await respondStatically(router, socket, startLine, uint16Arrays) {
            return true
        }
        return false
    }
    @inlinable
    func respondStatically<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable, let count: Int, T: StaticRouteResponderProtocol>(
        _ router: borrowing HTTPRouter,
        _ socket: borrowing Socket,
        _ startLine: DestinyRoutePathType,
        _ array: InlineArray<count, Route<T>>
    ) async throws -> Bool {
        for i in array.indices {
            if array.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: uint16Arrays.itemAt(index: i).responder)
                return true
            }
        }
        return false
    }
}

extension CompiledStaticResponderStorage {
    public struct Route<T: StaticRouteResponderProtocol>: CustomDebugStringConvertible, Sendable {
        public let path:DestinyRoutePathType
        public let responder:T

        public init(path: DestinyRoutePathType, responder: T) {
            self.path = path
            self.responder = responder
        }

        public var debugDescription: String {
            """
            Route<\(T.self)>(
                path: \(path.debugDescription),
                responder: \(responder.debugDescription)
            )
            """
        }
    }
}