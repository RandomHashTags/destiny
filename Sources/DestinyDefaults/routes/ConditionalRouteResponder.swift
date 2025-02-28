//
//  ConditionalRouteResponder.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import DestinyUtilities
import SwiftCompression

/// Default Conditional Route Responder implementation where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder<Request: RequestProtocol> : ConditionalRouteResponderProtocol {
    @usableFromInline
    private(set) var storage:Storage

    package var conditionsDescription:String = "[]"
    package var respondersDescription:String = "[]"

    public init(
        conditions: [@Sendable (inout Request) -> Bool],
        responders: [any RouteResponderProtocol]
    ) {
        storage = Storage(conditions: conditions, responders: responders)
    }

    public var debugDescription : String {
        return "ConditionalRouteResponder(\nconditions: \(conditionsDescription),\nresponders: \(respondersDescription)\n)"
    }

    @inlinable
    public func responder(for request: inout Request) -> (any RouteResponderProtocol)? {
        for (index, condition) in storage.conditions.enumerated() {
            if condition(&request) {
                return storage.responders[index]
            }
        }
        return nil
    }

    public mutating func register(responder: any RouteResponderProtocol, condition: @escaping @Sendable (inout Request) -> Bool) {
        storage.conditions.append(condition)
        storage.responders.append(responder)
    }
}

extension ConditionalRouteResponder {
    public struct Storage : Sendable {
        public fileprivate(set) var conditions:[@Sendable (inout Request) -> Bool]
        public fileprivate(set) var responders:[any RouteResponderProtocol]
    }
}