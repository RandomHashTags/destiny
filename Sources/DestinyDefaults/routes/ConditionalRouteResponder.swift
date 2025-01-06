//
//  ConditionalRouteResponder.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import DestinyUtilities
import SwiftCompression

/// Default Conditional Route Responder where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder : ConditionalRouteResponderProtocol {
    public private(set) var conditions:[@Sendable (inout RequestProtocol) -> Bool]
    public private(set) var responders:[RouteResponderProtocol]

    package var conditionsDescription:String = "[]"
    package var respondersDescription:String = "[]"

    public init(
        conditions: [@Sendable (inout RequestProtocol) -> Bool],
        responders: [RouteResponderProtocol]
    ) {
        self.conditions = conditions
        self.responders = responders
    }

    public var debugDescription : String {
        return "ConditionalRouteResponder(\nconditions: \(conditionsDescription),\nresponders: \(respondersDescription)\n)"
    }

    @inlinable
    public func responder(for request: inout RequestProtocol) -> RouteResponderProtocol? {
        for (index, condition) in conditions.enumerated() {
            if condition(&request) {
                return responders[index]
            }
        }
        return nil
    }

    public mutating func register(responder: RouteResponderProtocol, condition: @escaping @Sendable (inout RequestProtocol) -> Bool) {
        conditions.append(condition)
        responders.append(responder)
    }
}