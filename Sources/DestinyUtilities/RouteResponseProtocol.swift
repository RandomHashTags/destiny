//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

// MARK: RouteResponse
public protocol RouteResponseProtocol : Sendable {
    func respond(to socket: borrowing any SocketProtocol & ~Copyable) async throws
}