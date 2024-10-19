//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

// MARK: RouteResponse
public protocol RouteResponseProtocol : Sendable {
    var isAsync : Bool { get }
    func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws
    func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws
}