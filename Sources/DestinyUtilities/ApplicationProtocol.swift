//
//  ApplicationProtocol.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import Logging
import ServiceLifecycle

public protocol ApplicationProtocol : Service {
    
    #if canImport(Logging)
    /// The application's logger.
    var logger : Logger { get }
    #endif

    /// Shut down the application.
    func shutdown() async throws
}