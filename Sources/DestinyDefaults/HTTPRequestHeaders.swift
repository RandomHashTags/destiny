//
//  HTTPRequestHeaders.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#endif

import DestinyUtilities
import SwiftCompression

// MARK: HTTPRequestHeaders
/// Default storage for HTTP request headers.
public struct HTTPRequestHeaders : HTTPHeadersProtocol { // TODO: make SIMD
    public typealias Key = String
    public typealias Value = String

    // TODO: arrange for optimal memory layout
    @usableFromInline var custom:[String:String] = [:]

    public var accept:String?
    public var acceptCharset:Charset?
    #if canImport(FoundationEssentials)
    public var acceptDatetime:Date?
    #endif
    public var acceptEncoding:HTTPRequestHeader.AcceptEncoding?
    public var contentLength:Int?
    public var contentType:String?
    #if canImport(FoundationEssentials)
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

    public init(_ custom: [String:String] = [:]) {
        self.custom = custom
    }

    @inlinable
    public subscript(_ header: Key) -> Value? {
        get {
            return custom[header]
        }
        set {
            custom[header] = newValue
        }
    }

    @inlinable public func has(_ header: Key) -> Bool {
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

// MARK: Accept
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func accept<T: HTTPMediaTypeProtocol>(_ mediaType: T?) -> Self {
        accept = mediaType?.httpValue
        return self
    }
}

// MARK: Accept-Charset
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func acceptCharset(_ charset: Charset?) -> Self {
        acceptCharset = charset
        return self
    }
}

// MARK: Accept-Encoding
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func acceptEncoding(_ encoding: HTTPRequestHeader.AcceptEncoding?) -> Self {
        acceptEncoding = encoding
        return self
    }
}

// MARK: Content-Length
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func contentLength(_ length: Int?) -> Self {
        contentLength = length
        return self
    }
}

// MARK: Content-Type
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func contentType<T: HTTPMediaTypeProtocol>(_ mediaType: T?) -> Self {
        contentType = mediaType?.httpValue
        return self
    }
}

// MARK: Date
public extension HTTPRequestHeaders {
    #if canImport(FoundationEssentials)
    @discardableResult
    @inlinable
    mutating func date(_ date: Date?) -> Self {
        self.date = date
        return self
    }
    #endif
}

// MARK: From
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func from(_ emailAddress: String?) -> Self {
        from = emailAddress
        return self
    }
}

// MARK: Host
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func host(_ host: String?) -> Self {
        self.host = host
        return self
    }
}

// MARK: Max-Forwards
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func maxForwards(_ maxForwards: Int?) -> Self {
        self.maxForwards = maxForwards
        return self
    }
}

// MARK: Range
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func range(_ range: HTTPRequestHeader.Range?) -> Self {
        self.range = range
        return self
    }
}

// MARK: X-Requested-With
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func xRequestedWith(_ with: HTTPRequestHeader.XRequestedWith?) -> Self {
        xRequestedWith = with
        return self
    }
}

// MARK: X-Http-Method-Override
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func xHttpMethodOverride(_ method: HTTPRequestMethod?) -> Self {
        xHttpMethodOverride = method
        return self
    }
}

// MARK: Sec-GPC
public extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    mutating func secGPC(_ consented: Bool) -> Self {
        secGPC = consented
        return self
    }
}