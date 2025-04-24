//
//  FileMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

/// Core File Middleware protocol that allows files to be read.
public protocol FileMiddlewareProtocol: Sendable { // TODO: finish
    func load()
}