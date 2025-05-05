//
//  DynamicRouteResponder.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

import DestinyBlueprint
import DestinyUtilities

/// Default Dynamic Route Responder implementation that responds to dynamic routes.
public struct DynamicRouteResponder: DynamicRouteResponderProtocol {
    public let path:[PathComponent]
    public let parameterPathIndexes:[Int]
    public let defaultResponse:any DynamicResponseProtocol
    public let logic:@Sendable (inout any RequestProtocol, inout any DynamicResponseProtocol) async throws -> Void
    private let logicDebugDescription:String

    public init(
        path: [PathComponent],
        defaultResponse: any DynamicResponseProtocol,
        logic: @escaping @Sendable (inout any RequestProtocol, inout any DynamicResponseProtocol) async throws -> Void,
        logicDebugDescription: String = "{ _, _ in }"
    ) {
        self.path = path
        parameterPathIndexes = path.enumerated().compactMap({ $1.isParameter ? $0 : nil })
        self.defaultResponse = defaultResponse
        self.logic = logic
        self.logicDebugDescription = logicDebugDescription
    }

    public var debugDescription: String {
        "DynamicRouteResponder(path: \(path), defaultResponse: \(defaultResponse.debugDescription), logic: \(logicDebugDescription))"
    }

    @inlinable
    public func forEachPathComponent(_ yield: (PathComponent) -> Void) {
        for component in path {
            yield(component)
        }
    }

    @inlinable
    public var pathComponentsCount: Int {
        path.count
    }

    @inlinable
    public func pathComponent(at index: Int) -> PathComponent {
        path[index]
    }

    @inlinable
    public func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
        for index in parameterPathIndexes {
            yield(index)
        }
    }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(
        to socket: borrowing T,
        request: inout any RequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws {
        try await logic(&request, &response)
        try socket.writeString(response.message.string(escapeLineBreak: false))
    }
}