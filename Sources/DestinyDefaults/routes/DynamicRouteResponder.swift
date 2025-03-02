//
//  DynamicRouteResponder.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

import DestinyUtilities

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder : DynamicRouteResponderProtocol {
    public typealias ConcreteSocket = Socket
    public typealias ConcreteDynamicResponse = DynamicResponse

    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let defaultResponse:ConcreteDynamicResponse
    public let logic:@Sendable (inout ConcreteSocket.ConcreteRequest, inout ConcreteDynamicResponse) async throws -> Void
    private let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: ConcreteDynamicResponse,
        logic: @escaping @Sendable (inout ConcreteSocket.ConcreteRequest, inout ConcreteDynamicResponse) async throws -> Void,
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
    public func respond(
        to socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest,
        response: inout ConcreteDynamicResponse
    ) async throws {
        try await logic(&request, &response)
        try socket.writeString(response.response())
    }
}