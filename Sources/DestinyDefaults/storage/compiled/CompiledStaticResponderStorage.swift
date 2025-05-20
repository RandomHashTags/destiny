//
//  CompiledStaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 5/5/25.
//

import DestinyBlueprint

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage<
        let staticStringsCount: Int,
        let stringsCount: Int,
        let stringsWithDateHeaderCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: StaticResponderStorageProtocol {

    //let inlineArrays:InlineVLArray<Route<RouteResponses.InlineArrayProtocol>>
    public let staticStrings:InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>
    public let strings:InlineArray<stringsCount, Route<RouteResponses.String>>
    public let stringsWithDateHeader:InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>
    public let uint8Arrays:InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineVLArray<Route<RouteResponses.FoundationData>>
    #endif

    public init(
        //inlineArrays: [DestinyRoutePathType:RouteResponses.InlineArrayProtocol] = [:],
        staticStrings: InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>,
        strings: InlineArray<stringsCount, Route<RouteResponses.String>>,
        stringsWithDateHeader: InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>,
        uint8Arrays: InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>,
        uint16Arrays: InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>
    ) {
        //self.inlineArrays = inlineArrays
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
            var values:[String] = []
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
            staticStrings: \(debugDescription(for: staticStrings)),
            strings: \(debugDescription(for: strings)),
            stringsWithDateHeader: \(debugDescription(for: stringsWithDateHeader)),
            uint8Arrays: \(debugDescription(for: uint8Arrays)),
            uint16Arrays: \(debugDescription(for: uint16Arrays))
        )
        """
    }

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        for i in staticStrings.indices {
            if staticStrings.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: staticStrings.itemAt(index: i).responder)
                return true
            }
        }
        for i in strings.indices {
            if strings.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: strings.itemAt(index: i).responder)
                return true
            }
        }
        for i in stringsWithDateHeader.indices {
            if stringsWithDateHeader.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: stringsWithDateHeader.itemAt(index: i).responder)
                return true
            }
        }
        for i in uint8Arrays.indices {
            if uint8Arrays.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: uint8Arrays.itemAt(index: i).responder)
                return true
            }
        }
        for i in uint16Arrays.indices {
            if uint16Arrays.itemAt(index: i).path == startLine {
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