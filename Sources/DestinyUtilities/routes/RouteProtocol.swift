//
//  RouteProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes

/// The core Route protocol that powers Destiny's routing.
public protocol RouteProtocol : Sendable {
    /// The HTTPVersion associated with this route.
    var version : HTTPVersion! { get }
    
    /// The http method of this route.
    var method : HTTPRequest.Method { get }
}