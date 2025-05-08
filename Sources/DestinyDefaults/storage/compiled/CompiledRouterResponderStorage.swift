//
//  CompiledRouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 5/5/25.
//

import DestinyBlueprint
import DestinyUtilities

public struct CompiledRouterResponderStorage: RouterResponderStorageProtocol {
    public let `static`:CompiledStaticResponderStorage
    public var dynamic:DynamicResponderStorage
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    public init(
        static: CompiledStaticResponderStorage,
        dynamic: DynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}