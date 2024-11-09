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

public struct CompiledDynamicRoute : DynamicRouteResponseProtocol {
    public let isAsync:Bool
    public let path:[PathComponent]
    public let parameterPathIndexes:Set<Int>
    public let defaultResponse:DynamicResponseProtocol
    public let logic:(@Sendable (borrowing Request, inout DynamicResponseProtocol) throws -> Void)?
    public let logicAsync:(@Sendable (borrowing Request, inout DynamicResponseProtocol) async throws -> Void)?

    public init(
        async: Bool,
        path: [PathComponent],
        defaultResponse: DynamicResponseProtocol,
        logic: (@Sendable (borrowing Request, inout DynamicResponseProtocol) throws -> Void)?,
        logicAsync: (@Sendable (borrowing Request, inout DynamicResponseProtocol) async throws -> Void)?
    ) {
        isAsync = async
        self.path = path
        parameterPathIndexes = Set(path.enumerated().compactMap({ $1.isParameter ? $0 : nil }))
        self.defaultResponse = defaultResponse
        self.logic = logic
        self.logicAsync = logicAsync
    }


    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) throws {
        try logic!(request, &response)
        try response.response().utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
    @inlinable
    public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) async throws {
        try await logicAsync!(request, &response)
        try response.response().utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}