//
//  ConditionalRouteResponder.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import DestinyBlueprint
import DestinyUtilities
import SwiftCompression

/// Default Conditional Route Responder implementation where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder: ConditionalRouteResponderProtocol {
    public private(set) var staticConditions:[@Sendable (inout any RequestProtocol) -> Bool]
    public private(set) var staticResponders:[any StaticRouteResponderProtocol]
    public private(set) var dynamicConditions:[@Sendable (inout any RequestProtocol) -> Bool]
    public private(set) var dynamicResponders:[any DynamicRouteResponderProtocol]

    package var staticConditionsDescription = "[]"
    package var staticRespondersDescription = "[]"
    package var dynamicConditionsDescription = "[]"
    package var dynamicRespondersDescription = "[]"

    public init(
        staticConditions: [@Sendable (inout any RequestProtocol) -> Bool],
        staticResponders: [any StaticRouteResponderProtocol],
        dynamicConditions: [@Sendable (inout any RequestProtocol) -> Bool],
        dynamicResponders: [any DynamicRouteResponderProtocol]
    ) {
        self.staticConditions = staticConditions
        self.staticResponders = staticResponders
        self.dynamicConditions = dynamicConditions
        self.dynamicResponders = dynamicResponders
    }

    public var debugDescription: String {
        """
        ConditionalRouteResponder(
            staticConditions: \(staticConditionsDescription),
            staticResponders: \(staticRespondersDescription),
            dynamicConditions: \(dynamicConditionsDescription),
            dynamicResponders: \(dynamicRespondersDescription)
        )
        """
    }

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        request: inout any RequestProtocol
    ) async throws -> Bool {
        for (index, condition) in staticConditions.enumerated() {
            if condition(&request) {
                try await staticResponders[index].respond(to: socket)
                return true
            }
        }
        for (index, condition) in dynamicConditions.enumerated() {
            if condition(&request) {
                let responder = dynamicResponders[index]
                var response = responder.defaultResponse
                try await responder.respond(to: socket, request: &request, response: &response)
                return true
            }
        }
        return false
    }
}