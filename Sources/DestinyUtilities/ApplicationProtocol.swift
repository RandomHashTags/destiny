//
//  ApplicationProtocol.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

#if canImport(Logging)
import Logging
#endif

#if canImport(ServiceLifecycle)
import ServiceLifecycle
#endif

public protocol ApplicationProtocol : Service {
    
    #if canImport(Logging)
    /// The application's logger.
    var logger : Logger { get }
    #endif

    /// Shut down the application.
    func shutdown() async throws
}