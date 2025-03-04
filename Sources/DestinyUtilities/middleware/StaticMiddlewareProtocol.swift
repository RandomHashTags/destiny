//
//  StaticMiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

/// Core Static Middleware protocol which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol : MiddlewareProtocol {
    associatedtype ConcreteHTTPCookie:HTTPCookieProtocol
    associatedtype ConcreteHTTPResponseHeaders:HTTPHeadersProtocol
    associatedtype ConcreteHTTPRequestMethod:HTTPRequestMethodProtocol

    /// Route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    var handlesVersions : Set<HTTPVersion>? { get }

    /// Route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    var handlesMethods : Set<ConcreteHTTPRequestMethod>? { get }

    /// Route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    var handlesStatuses : Set<HTTPResponseStatus>? { get }

    /// The route content types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    var handlesContentTypes : Set<HTTPMediaType>? { get }

    /// Response http version this middleware applies to routes.
    var appliesVersion : HTTPVersion? { get }

    /// Response status this middleware applies to routes.
    var appliesStatus : HTTPResponseStatus? { get }

    /// Response content type this middleware applies to routes.
    var appliesContentType : HTTPMediaType? { get }
    
    /// Response headers this middleware applies to routes.
    var appliesHeaders : ConcreteHTTPResponseHeaders { get }

    /// Response cookies this middleware applies to routes.
    var appliesCookies : [ConcreteHTTPCookie] { get }

    /// Whether or not this middleware handles a route with the given options.
    @inlinable
    func handles(
        version: HTTPVersion,
        method: ConcreteHTTPRequestMethod,
        contentType: HTTPMediaType,
        status: HTTPResponseStatus
    ) -> Bool

    /// Updates the given variables by applying this middleware.
    @inlinable
    func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType,
        status: inout HTTPResponseStatus,
        headers: inout ConcreteHTTPResponseHeaders,
        cookies: inout [ConcreteHTTPCookie]
    )
}

extension StaticMiddlewareProtocol {
    @inlinable
    public func handles(
        version: HTTPVersion,
        method: ConcreteHTTPRequestMethod,
        contentType: HTTPMediaType,
        status: HTTPResponseStatus
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
        status: inout HTTPResponseStatus,
        headers: inout ConcreteHTTPResponseHeaders,
        cookies: inout [ConcreteHTTPCookie]
    ) {
        if let appliesVersion:HTTPVersion = appliesVersion {
            version = appliesVersion
        }
        if let appliesStatus:HTTPResponseStatus = appliesStatus {
            status = appliesStatus
        }
        if let appliesContentType:HTTPMediaType = appliesContentType {
            contentType = appliesContentType
        }
        headers.merge(appliesHeaders)
        cookies.append(contentsOf: appliesCookies)
    }
}