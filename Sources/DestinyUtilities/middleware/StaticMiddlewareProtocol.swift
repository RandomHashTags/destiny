//
//  StaticMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes

/// The core `MiddlewareProtocol` that powers Destiny's static middleware which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    /// The route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    var handlesVersions : Set<HTTPVersion>? { get }

    /// The route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    var handlesMethods : Set<HTTPRequest.Method>? { get }

    /// The route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    var handlesStatuses : Set<HTTPResponse.Status>? { get }

    /// The route content types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    var handlesContentTypes : Set<HTTPMediaType>? { get }

    /// The response version this middleware applies to routes.
    var appliesVersion : HTTPVersion? { get }

    /// The response status this middleware applies to routes.
    var appliesStatus : HTTPResponse.Status? { get }

    /// The response content type this middleware applies to routes.
    var appliesContentType : HTTPMediaType? { get }
    
    /// The response headers this middleware applies to routes.
    var appliesHeaders : [String:String] { get }

    /// Whether or not this middleware handles a route with the given options.
    @inlinable
    func handles(
        version: HTTPVersion,
        method: HTTPRequest.Method,
        contentType: HTTPMediaType,
        status: HTTPResponse.Status
    ) -> Bool
}
public extension StaticMiddlewareProtocol {
    @inlinable
    func handles(
        version: HTTPVersion,
        method: HTTPRequest.Method,
        contentType: HTTPMediaType,
        status: HTTPResponse.Status
    ) -> Bool {
        return (handlesVersions == nil || handlesVersions!.contains(version))
            && (handlesMethods == nil || handlesMethods!.contains(method))
            && (handlesContentTypes == nil || handlesContentTypes!.contains(contentType))
            && (handlesStatuses == nil || handlesStatuses!.contains(status))
    }
}