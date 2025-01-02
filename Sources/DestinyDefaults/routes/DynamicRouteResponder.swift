//
//  DynamicRouteResponder.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

/// The default Dynamic Route Responder that responds to dynamic routes.
public struct DynamicRouteResponder : DynamicRouteResponderProtocol {
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let defaultResponse:DynamicResponseProtocol
    public let logic:@Sendable (inout RequestProtocol, inout DynamicResponseProtocol) async throws -> Void
    private let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: DynamicResponseProtocol,
        logic: @escaping @Sendable (inout RequestProtocol, inout DynamicResponseProtocol) async throws -> Void,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self.defaultResponse = defaultResponse
        self.logic = logic
        self.logicDebugDescription = logicDebugDescription
    }

    public var debugDescription : String {
        return "DynamicRouteResponder(path: \(path), defaultResponse: \(defaultResponse.debugDescription), logic: \(logicDebugDescription))"
    }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws {
        try await logic(&request, &response)
        try response.response().utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}