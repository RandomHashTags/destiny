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
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    public init(
        static: [DestinyRoutePathType:any StaticRouteResponderProtocol],
        dynamic: DynamicResponses,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}