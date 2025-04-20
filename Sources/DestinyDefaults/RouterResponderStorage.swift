//
//  RouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

import DestinyBlueprint
import DestinyUtilities

public struct RouterResponderStorage : RouterResponderStorageProtocol {
    public var `static`:StaticResponderStorage
    public var dynamic:DynamicResponderStorage
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    public init(
        static: StaticResponderStorage,
        dynamic: DynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}