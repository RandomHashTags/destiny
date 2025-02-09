//
//  RouteProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

#if canImport(SwiftCompression)
import SwiftCompression
#endif

/// Core Route protocol.
public protocol RouteProtocol : CustomDebugStringConvertible, Sendable {
    /// `HTTPVersion` associated with this route.
    var version : HTTPVersion { get }
    
    /// HTTP Request Method of this route.
    var method : HTTPRequestMethod { get }

    #if canImport(SwiftCompression)
    /// Supported compression algorithms that this route can use to compress its response.
    var supportedCompressionAlgorithms : Set<CompressionAlgorithm> { get set }
    #endif
}