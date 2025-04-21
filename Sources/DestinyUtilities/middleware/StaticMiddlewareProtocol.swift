//
//  StaticMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyBlueprint

/// Core Static Middleware protocol which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    associatedtype Cookie:HTTPCookieProtocol

    /// Route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    var handlesVersions : Set<HTTPVersion>? { get }

    /// Route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    var handlesMethods : Set<HTTPRequestMethod>? { get }

    /// Route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    var handlesStatuses : Set<HTTPResponseStatus.Code>? { get }

    /// The route content types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    var handlesContentTypes : Set<HTTPMediaType>? { get }

    /// Response http version this middleware applies to routes.
    var appliesVersion : HTTPVersion? { get }

    /// Response status this middleware applies to routes.
    var appliesStatus : HTTPResponseStatus.Code? { get }

    /// Response content type this middleware applies to routes.
    var appliesContentType : HTTPMediaType? { get }
    
    /// Response headers this middleware applies to routes.
    var appliesHeaders : [String:String] { get }

    /// Response cookies this middleware applies to routes.
    var appliesCookies : [Cookie] { get }

    /// Whether or not this middleware handles a route with the given options.
    @inlinable
    func handles(
        version: HTTPVersion,
        method: HTTPRequestMethod,
        contentType: HTTPMediaType,
        status: HTTPResponseStatus.Code
    ) -> Bool

    /// Updates the given variables by applying this middleware.
    @inlinable
    func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType,
        status: inout HTTPResponseStatus.Code,
        headers: inout [String:String],
        cookies: inout [any HTTPCookieProtocol]
    )
}
extension StaticMiddlewareProtocol {
    @inlinable
    public func handles(
        version: HTTPVersion,
        method: HTTPRequestMethod,
        contentType: HTTPMediaType,
        status: HTTPResponseStatus.Code
    ) -> Bool {
        return (handlesVersions == nil || handlesVersions!.contains(version))
            && (handlesMethods == nil || handlesMethods!.contains(method))
            && (handlesContentTypes == nil || handlesContentTypes!.contains(contentType))
            && (handlesStatuses == nil || handlesStatuses!.contains(status))
    }

    @inlinable
    public func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType,
        status: inout HTTPResponseStatus.Code,
        headers: inout [String:String],
        cookies: inout [any HTTPCookieProtocol]
    ) {
        if let appliesVersion {
            version = appliesVersion
        }
        if let appliesStatus {
            status = appliesStatus
        }
        if let appliesContentType {
            contentType = appliesContentType
        }
        for (header, value) in appliesHeaders {
            headers[header] = value
        }
        cookies.append(contentsOf: appliesCookies)
    }

    @inlinable
    public func apply<T: DynamicResponseProtocol>(
        contentType: inout HTTPMediaType,
        to response: inout T
    ) {
        if let appliesVersion {
            response.message.version = appliesVersion
        }
        if let appliesStatus {
            response.message.status = appliesStatus
        }
        if let appliesContentType {
            contentType = appliesContentType
        }
        for (header, value) in appliesHeaders {
            response.message.setHeader(key: header, value: value)
        }
        for cookie in appliesCookies {
            response.message.appendCookie(cookie)
        }
        // TODO: fix
    }
}