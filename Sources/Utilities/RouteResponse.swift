//
//  RouteResponse.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

// MARK: RouteResponse
public protocol RouteResponseProtocol : Sendable {
    func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws
}