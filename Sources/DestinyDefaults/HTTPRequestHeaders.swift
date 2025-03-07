//
//  HTTPRequestHeaders.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyUtilities
import SwiftCompression

// MARK: HTTPRequestHeaders
/// Default storage for HTTP request headers.
public struct HTTPRequestHeaders : HTTPRequestHeadersProtocol { // TODO: make SIMD
    // TODO: arrange for optimal memory layout
    public var custom:[String:String] = [:]

    public var accept:String?
    public var acceptCharset:Charset?
    #if canImport(FoundationEssentials) || canImport(Foundation)
    public var acceptDatetime:Date?
    #endif
    public var acceptEncoding:HTTPRequestHeader.AcceptEncoding?
    public var contentLength:Int?
    public var contentType:String?

    #if canImport(FoundationEssentials) || canImport(Foundation)
    public var date:Date?
    #endif

    public var from:String?
    public var host:String?
    public var maxForwards:Int?
    public var range:HTTPRequestHeader.Range?

    public var upgradeInsecureRequests:Bool = false
    public var xRequestedWith:HTTPRequestHeader.XRequestedWith?
    public var dnt:Bool?
    public var xHttpMethodOverride:HTTPRequestMethod?
    public var secGPC:Bool = false

    public init() {
    }
    public init(
        accept: String? = nil,
        acceptCharset: Charset? = nil,
        acceptEncoding: HTTPRequestHeader.AcceptEncoding? = nil,
        contentLength: Int? = nil,
        contentType: String? = nil,
        from: String? = nil,
        host: String? = nil,
        maxForwards: Int? = nil,
        range: HTTPRequestHeader.Range? = nil,

        upgradeInsecureRequests: Bool = false,
        xRequestedWith: HTTPRequestHeader.XRequestedWith? = nil,
        dnt: Bool? = nil,
        xHttpMethodOverride: HTTPRequestMethod? = nil,
        secGPC: Bool = false,

        custom: [String:String] = [:]
    ) {
        self.accept = accept
        self.acceptCharset = acceptCharset
        self.acceptEncoding = acceptEncoding
        self.contentLength = contentLength
        self.from = from
        self.host = host
        self.maxForwards = maxForwards
        self.range = range
        self.upgradeInsecureRequests = upgradeInsecureRequests
        self.xRequestedWith = xRequestedWith
        self.dnt = dnt
        self.xHttpMethodOverride = xHttpMethodOverride
        self.secGPC = secGPC
        self.custom = custom
    }

    @inlinable
    public subscript(_ header: String) -> String? {
        get { custom[header] }
        set { custom[header] = newValue }
    }

    @inlinable
    public subscript(_ header: String, default defaultValue: @autoclosure () -> String) -> String {
        get { custom[header, default: defaultValue()] }
        set { custom[header] = newValue }
    }

    @inlinable public func has(_ header: String) -> Bool {
        return custom[header] != nil
    }

    @inlinable
    public mutating func add(_ value: String, header: String) {
        if let existingValue:String = custom[header] {
            custom[header] = existingValue + "," + value
        } else {
            custom[header] = value
        }
    }    
}

// MARK: Merge
extension HTTPRequestHeaders {
    @inlinable
    public mutating func merge<T: HTTPRequestHeadersProtocol>(_ headers: T) { // TODO: finish
    }
}

// MARK: Iterate
extension HTTPRequestHeaders {
    @inlinable
    public func iterate(yield: (String, String) -> Void) {
    }
}

// MARK: DebugDescription
extension HTTPRequestHeaders {
    public var debugDescription : String {
        var values:[String] = []
        if let accept { values.append("accept: \"\(accept)\"") }
        if let acceptCharset { values.append("acceptCharset: .\(acceptCharset)") }
        if let acceptEncoding { values.append("acceptEncoding: .\(acceptEncoding)") }
        if let contentLength { values.append("contentLength: \(contentLength)") }
        if let contentType { values.append("contentType: \"\(contentType)\"") }
        if let from { values.append("from: \"\(from)\"") }
        if let host { values.append("host: \"\(host)\"") }
        if let maxForwards { values.append("maxForwards: \(maxForwards)") }
        if let range { values.append("range: .\(range)") }
        if upgradeInsecureRequests { values.append("upgradeInsecureRequests: true") }
        if let xRequestedWith { values.append("xRequestedWith: .\(xRequestedWith)") }
        if let dnt { values.append("dnt: \(dnt)") }
        if let xHttpMethodOverride { values.append("xHttpMethodOverride: .\(xHttpMethodOverride)") }
        if secGPC { values.append("secGPC: true") }
        if !custom.isEmpty { values.append("custom: \(custom)") }
        return "HTTPRequestHeaders(\(values.joined(separator: ",")))"
    }
}

// MARK: Accept
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func accept(_ mediaType: HTTPMediaType?) -> Self {
        accept = mediaType?.description
        return self
    }
}

// MARK: Accept-Charset
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func acceptCharset(_ charset: Charset?) -> Self {
        acceptCharset = charset
        return self
    }
}

// MARK: Accept-Encoding
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func acceptEncoding(_ encoding: HTTPRequestHeader.AcceptEncoding?) -> Self {
        acceptEncoding = encoding
        return self
    }
}

// MARK: Content-Length
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func contentLength(_ length: Int?) -> Self {
        contentLength = length
        return self
    }
}

// MARK: Content-Type
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func contentType(_ mediaType: HTTPMediaType?) -> Self {
        contentType = mediaType?.description
        return self
    }
}

// MARK: Date
extension HTTPRequestHeaders {
    #if canImport(FoundationEssentials)
    @discardableResult
    @inlinable
    public mutating func date(_ date: Date?) -> Self {
        self.date = date
        return self
    }
    #endif
}

// MARK: From
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func from(_ emailAddress: String?) -> Self {
        from = emailAddress
        return self
    }
}

// MARK: Host
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func host(_ host: String?) -> Self {
        self.host = host
        return self
    }
}

// MARK: Max-Forwards
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func maxForwards(_ maxForwards: Int?) -> Self {
        self.maxForwards = maxForwards
        return self
    }
}

// MARK: Range
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func range(_ range: HTTPRequestHeader.Range?) -> Self {
        self.range = range
        return self
    }
}

// MARK: X-Requested-With
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func xRequestedWith(_ with: HTTPRequestHeader.XRequestedWith?) -> Self {
        xRequestedWith = with
        return self
    }
}

// MARK: X-Http-Method-Override
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func xHttpMethodOverride(_ method: HTTPRequestMethod?) -> Self {
        xHttpMethodOverride = method
        return self
    }
}

// MARK: Sec-GPC
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func secGPC(_ consented: Bool) -> Self {
        secGPC = consented
        return self
    }
}