//
//  RouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

import DestinyUtilities

public struct RouterResponderStorage<Request: RequestProtocol> : Sendable {
    public var `static`:StaticResponderStorage
    public var dynamic:DynamicResponderStorage
    public var conditional:[DestinyRoutePathType:ConditionalRouteResponder<Request>]

    public init(
        static: StaticResponderStorage = .init(),
        dynamic: DynamicResponderStorage = .init(),
        conditional: [DestinyRoutePathType:ConditionalRouteResponder<Request>] = [:]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}