//
//  CORSMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 12/8/24.
//

/// The convenience protocol that indicates the middleware controls CORS.
public protocol CORSMiddlewareProtocol : MiddlewareProtocol {
}

public enum CORSMiddlewareAllowedOrigin : Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased
}