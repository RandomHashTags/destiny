//
//  StaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 3/2/25.
//

import DestinyBlueprint
import DestinyUtilities

/// Default storage that handles static routes.
public struct StaticResponderStorage: StaticResponderStorageProtocol {

    @usableFromInline var inlineArrays:[DestinyRoutePathType:RouteResponses.InlineArrayProtocol]
    @usableFromInline var staticStrings:[DestinyRoutePathType:RouteResponses.StaticString]
    @usableFromInline var strings:[DestinyRoutePathType:RouteResponses.String]
    @usableFromInline var uint8Arrays:[DestinyRoutePathType:RouteResponses.UInt8Array]
    @usableFromInline var uint16Arrays:[DestinyRoutePathType:RouteResponses.UInt16Array]

    #if canImport(FoundationEssentials) || canImport(Foundation)
    @usableFromInline var foundationData:[DestinyRoutePathType:RouteResponses.FoundationData]
    #endif

    public init(
        inlineArrays: [DestinyRoutePathType:RouteResponses.InlineArrayProtocol] = [:],
        staticStrings: [DestinyRoutePathType:RouteResponses.StaticString] = [:],
        strings: [DestinyRoutePathType:RouteResponses.String] = [:],
        uint8Arrays: [DestinyRoutePathType:RouteResponses.UInt8Array] = [:],
        uint16Arrays: [DestinyRoutePathType:RouteResponses.UInt16Array] = [:]
    ) {
        self.inlineArrays = inlineArrays
        self.staticStrings = staticStrings
        self.strings = strings
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        foundationData = [:]
        #endif
    }

    @inlinable
    public func respond<Socket: SocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        with startLine: DestinyRoutePathType
    ) async throws -> Bool {
        if let r = inlineArrays[startLine] {
            try await r.respond(to: socket)
        } else if let r = staticStrings[startLine] {
            try await r.respond(to: socket)
        } else if let r = strings[startLine] {
            try await r.respond(to: socket)
        } else if let r = uint8Arrays[startLine] {
            try await r.respond(to: socket)
        } else if let r = uint16Arrays[startLine] {
            try await r.respond(to: socket)
        } else {
            #if canImport(FoundationEssentials) || canImport(Foundation)
            if let r = foundationData[startLine] {
                try await r.respond(to: socket)
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