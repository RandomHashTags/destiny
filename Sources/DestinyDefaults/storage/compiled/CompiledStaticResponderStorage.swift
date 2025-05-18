//
//  CompiledStaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 5/5/25.
//

import DestinyBlueprint
import DestinyUtilities

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage<
        let staticStringsCount: Int,
        let stringsCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: StaticResponderStorageProtocol {

    //let inlineArrays:InlineVLArray<Route<RouteResponses.InlineArrayProtocol>>
    public let staticStrings:InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>
    public let strings:InlineArray<stringsCount, Route<RouteResponses.String>>
    public let uint8Arrays:InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineVLArray<Route<RouteResponses.FoundationData>>
    #endif

    public init(
        //inlineArrays: [DestinyRoutePathType:RouteResponses.InlineArrayProtocol] = [:],
        staticStrings: InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>,
        strings: InlineArray<stringsCount, Route<RouteResponses.String>>,
        uint8Arrays: InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>,
        uint16Arrays: InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>
    ) {
        //self.inlineArrays = inlineArrays
        self.staticStrings = staticStrings
        self.strings = strings
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        //foundationData = []
        #endif
    }

    public var debugDescription: String {
        "" // TODO: finish
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
    public struct Route<T: StaticRouteResponderProtocol>: Sendable {
        public let path:DestinyRoutePathType
        public let responder:T

        public init(path: DestinyRoutePathType, responder: T) {
            self.path = path
            self.responder = responder
        }
    }
}