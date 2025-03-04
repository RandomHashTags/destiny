//
//  ConditionalRouteResponder.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import DestinyUtilities

/// Default Conditional Route Responder implementation where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder : ConditionalRouteResponderProtocol {
    public typealias ConcreteRequest = Request

    @usableFromInline
    private(set) var storage:Storage

    package var conditionsDescription:String = "[]"
    package var respondersDescription:String = "[]"

    public init(
        conditions: [@Sendable (inout ConcreteRequest) -> Bool],
        responders: [any RouteResponderProtocol]
    ) {
        storage = Storage(conditions: conditions, responders: responders)
    }

    public var debugDescription : String {
        return "ConditionalRouteResponder(\nconditions: \(conditionsDescription),\nresponders: \(respondersDescription)\n)"
    }

    @inlinable
    public func responder(for request: inout ConcreteRequest) -> (any RouteResponderProtocol)? {
        for (index, condition) in storage.conditions.enumerated() {
            if condition(&request) {
                return storage.responders[index]
            }
        }
        return nil
    }

    public mutating func register(responder: any RouteResponderProtocol, condition: @escaping @Sendable (inout ConcreteRequest) -> Bool) {
        storage.conditions.append(condition)
        storage.responders.append(responder)
    }
}

extension ConditionalRouteResponder {
    public struct Storage : Sendable {
        public fileprivate(set) var conditions:[@Sendable (inout ConcreteRequest) -> Bool]
        public fileprivate(set) var responders:[any RouteResponderProtocol]
    }
}