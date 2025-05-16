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

    @usableFromInline var staticStrings:[DestinyRoutePathType:RouteResponses.StaticString]
    @usableFromInline var strings:[DestinyRoutePathType:RouteResponses.String]
    @usableFromInline var stringsWithDateHeader:[DestinyRoutePathType:RouteResponses.StringWithDateHeader]
    @usableFromInline var uint8Arrays:[DestinyRoutePathType:RouteResponses.UInt8Array]
    @usableFromInline var uint16Arrays:[DestinyRoutePathType:RouteResponses.UInt16Array]

    #if canImport(FoundationEssentials) || canImport(Foundation)
    @usableFromInline var foundationData:[DestinyRoutePathType:RouteResponses.FoundationData]
    #endif

    public init(
        staticStrings: [DestinyRoutePathType:RouteResponses.StaticString] = [:],
        strings: [DestinyRoutePathType:RouteResponses.String] = [:],
        stringsWithDateHeader: [DestinyRoutePathType:RouteResponses.StringWithDateHeader] = [:],
        uint8Arrays: [DestinyRoutePathType:RouteResponses.UInt8Array] = [:],
        uint16Arrays: [DestinyRoutePathType:RouteResponses.UInt16Array] = [:]
    ) {
        self.staticStrings = staticStrings
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        foundationData = [:]
        #endif
    }

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        if let r = staticStrings[startLine] {
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