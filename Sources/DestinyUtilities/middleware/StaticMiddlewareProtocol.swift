//
//  StaticMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes

/// The core `MiddlewareProtocol` that powers Destiny's static middleware which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    /// What static & dynamic route request versions this middleware handles at compile time.
    /// - Warning: `nil` makes it handle all versions.
    var handlesVersions : Set<HTTPVersion>? { get }
    /// What static & dynamic route request methods this middleware handles at compile time.
    /// - Warning: `nil` makes it handle all methods.
    var handlesMethods : Set<HTTPRequest.Method>? { get }
    /// What static & dynamic route response statuses this middleware handles at compile time.
    /// - Warning: `nil` makes it handle all statuses.
    var handlesStatuses : Set<HTTPResponse.Status>? { get }
    /// What static & dynamic route content types this middleware handles at compile time.
    /// - Warning: `nil` makes it handle all content types.
    var handlesContentTypes : Set<HTTPMediaType>? { get }

    /// What response version this middleware applies to static & dynamic routes at compile time.
    var appliesVersion : HTTPVersion? { get }
    /// What response status this middleware applies to static & dynamic routes at compile time.
    var appliesStatus : HTTPResponse.Status? { get }
    /// What response content type this middleware applies to static & dynamic routes at compile time.
    var appliesContentType : HTTPMediaType? { get }
    /// What response headers this middleware applies to static & dynamic routes at compile time.
    var appliesHeaders : [String:String] { get }
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