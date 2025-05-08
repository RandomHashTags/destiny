//
//  CompiledStaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 5/5/25.
//

import DestinyBlueprint
import DestinyUtilities

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage: StaticResponderStorageProtocol {

    //let inlineArrays:InlineVLArray<Route<RouteResponses.InlineArrayProtocol>>
    public let staticStrings:InlineVLArray<Route<RouteResponses.StaticString>>
    public let strings:InlineVLArray<Route<RouteResponses.String>>
    public let uint8Arrays:InlineVLArray<Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineVLArray<Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineVLArray<Route<RouteResponses.FoundationData>>
    #endif

    public init(
        //inlineArrays: [DestinyRoutePathType:RouteResponses.InlineArrayProtocol] = [:],
        staticStrings: InlineVLArray<Route<RouteResponses.StaticString>>,
        strings: InlineVLArray<Route<RouteResponses.String>>,
        uint8Arrays: InlineVLArray<Route<RouteResponses.UInt8Array>>,
        uint16Arrays: InlineVLArray<Route<RouteResponses.UInt16Array>>
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

    @inlinable
    public func respond<Socket: SocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        with startLine: DestinyRoutePathType
    ) async throws -> Bool {
        var i = 0
        while i < staticStrings.count {
            if staticStrings.itemAt(index: i).path == startLine {
                try await staticStrings.itemAt(index: i).responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < strings.count {
            if strings.itemAt(index: i).path == startLine {
                try await strings.itemAt(index: i).responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < uint8Arrays.count {
            if uint8Arrays.itemAt(index: i).path == startLine {
                try await uint8Arrays.itemAt(index: i).responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < uint16Arrays.count {
            if uint16Arrays.itemAt(index: i).path == startLine {
                try await uint16Arrays.itemAt(index: i).responder.respond(to: socket)
                return true
            }
            i += 1
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