//
//  CompiledRouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 5/5/25.
//

import DestinyBlueprint
import DestinyUtilities

public struct CompiledRouterResponderStorage<
        let staticStringsCount: Int,
        let stringsCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: RouterResponderStorageProtocol {
    public let `static`:CompiledStaticResponderStorage<staticStringsCount, stringsCount, uint8ArraysCount, uint16ArraysCount>
    public var dynamic:DynamicResponderStorage
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    public init(
        static: CompiledStaticResponderStorage<staticStringsCount, stringsCount, uint8ArraysCount, uint16ArraysCount>,
        dynamic: DynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}