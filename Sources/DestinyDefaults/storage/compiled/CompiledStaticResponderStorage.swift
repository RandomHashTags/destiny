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

    //let inlineArrays:InlineArray<inlineArraysCount, Route<RouteResponses.InlineArrayProtocol>>
    public let staticStrings:InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>
    public let strings:InlineArray<stringsCount, Route<RouteResponses.String>>
    public let uint8Arrays:InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineArray<foundationDataCount, Route<RouteResponses.FoundationData>>
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

    @inlinable
    public func respond<Socket: SocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        with startLine: DestinyRoutePathType
    ) async throws -> Bool {
        var i = 0
        while i < staticStringsCount {
            if staticStrings[i].path == startLine {
                try await staticStrings[i].responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < stringsCount {
            if strings[i].path == startLine {
                try await strings[i].responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < uint8ArraysCount {
            if uint8Arrays[i].path == startLine {
                try await uint8Arrays[i].responder.respond(to: socket)
                return true
            }
            i += 1
        }
        i = 0
        while i < uint16ArraysCount {
            if uint16Arrays[i].path == startLine {
                try await uint16Arrays[i].responder.respond(to: socket)
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