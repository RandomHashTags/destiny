//
//  CompiledDynamicRoute.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

public struct CompiledDynamicRoute : DynamicRouteResponderProtocol {
    public let path:[PathComponent]
    public let parameterPathIndexes:Set<Int>
    public let defaultResponse:DynamicResponseProtocol
    public let logic:@Sendable (inout RequestProtocol, inout DynamicResponseProtocol) async throws -> Void

    public init(
        path: [PathComponent],
        defaultResponse: DynamicResponseProtocol,
        logic: @escaping @Sendable (inout RequestProtocol, inout DynamicResponseProtocol) throws -> Void
    ) {
        self.path = path
        parameterPathIndexes = Set(path.enumerated().compactMap({ $1.isParameter ? $0 : nil }))
        self.defaultResponse = defaultResponse
        self.logic = logic
    }

    public var debugDescription : String {
        return "CompiledDynamicRoute(path: \(path), defaultResponse: \(defaultResponse), logic: nil)" // TODO: fix
    }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws {
        try await logic(&request, &response)
        try response.response().utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}