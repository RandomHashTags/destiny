//
//  ApplicationProtocol.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import Logging
import ServiceLifecycle

public protocol ApplicationProtocol : Service {
    
    /// The application's logger.
    var logger : Logger { get }

    /// Shut down the application.
    func shutdown() async throws
}