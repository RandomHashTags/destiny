//
//  ServerProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import ServiceLifecycle

public protocol ServerProtocol : Service {
    typealias ClientSocket = SocketProtocol & ~Copyable
    typealias ServerRouter = RouterProtocol & ~Copyable
}