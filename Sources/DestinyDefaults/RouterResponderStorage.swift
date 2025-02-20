//
//  RouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

import DestinyUtilities

public struct RouterResponderStorage : Sendable {
    public var `static`:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public var dynamic:DynamicResponses
    public var conditional:[DestinyRoutePathType:ConditionalRouteResponderProtocol]

    public init(
        static: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamic: DynamicResponses,
        conditional: [DestinyRoutePathType:ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}