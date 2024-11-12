//
//  ServerProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import ServiceLifecycle

public protocol ServerProtocol : Service {
    associatedtype ClientSocket = SocketProtocol
    associatedtype ClientRequest = RequestProtocol
    associatedtype ServerRouter = RouterProtocol
}