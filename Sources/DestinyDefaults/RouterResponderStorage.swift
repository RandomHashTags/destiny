//
//  RouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

import DestinyUtilities

public struct RouterResponderStorage : Sendable {
    public var `static`:[DestinyRoutePathType:any StaticRouteResponderProtocol]
    public var dynamic:DynamicResponses
    public var conditional:[DestinyRoutePathType:ConditionalRouteResponder]

    public init(
        static: [DestinyRoutePathType:any StaticRouteResponderProtocol],
        dynamic: DynamicResponses,
        conditional: [DestinyRoutePathType:ConditionalRouteResponder]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}