//
//  HTTPResponseHeaders.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#endif

import DestinyUtilities
import SwiftCompression

// MARK: HTTPResponseHeaders
/// Default storage for HTTP response headers.
public struct HTTPResponseHeaders : HTTPHeadersProtocol { // TODO: finish
    public typealias Key = String
    public typealias Value = String

    @usableFromInline var custom:[String:String] = [:]

    // TODO: arrange for optimal memory layout
    @usableFromInline var acceptRanges:HTTPResponseHeader.AcceptRanges?
    @usableFromInline var age:Int?
    public var allow:String?
    @usableFromInline var contentEncoding:CompressionAlgorithm?
    @usableFromInline var contentLength:Int?
    @usableFromInline var contentType:String?
    @usableFromInline var retryAfterDuration:Int?
    #if canImport(FoundationEssentials)
    @usableFromInline var retryAfterDate:Date?
    #endif
    @usableFromInline var tk:HTTPResponseHeader.TK?
    @usableFromInline var xContentTypeOptions:Bool = false
    

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

    @inlinable
    public func has(_ header: Key) -> Bool {
        return custom[header] != nil
    }
}

// MARK: Accept-Ranges
public extension HTTPResponseHeaders {
    @inlinable
    mutating func acceptRanges(_ ranges: HTTPResponseHeader.AcceptRanges?) -> Self {
        acceptRanges = ranges
        return self
    }
}

// MARK: Age
public extension HTTPResponseHeaders {
    @inlinable
    mutating func age(_ age: Int?) -> Self {
        self.age = age
        return self
    }
}

// MARK: Allow
public extension HTTPResponseHeaders {
    @inlinable
    mutating func allow<C: Collection<HTTPRequestMethod>>(_ methods: C?) -> Self {
        var temp:String = ""
        if let methods:C {
            var has:Bool = false
            for method in methods {
                if has {
                    temp += ", "
                }
                temp += method.rawName
                has = true
            }
        }
        allow = temp
        return self
    }
}

// MARK: Content-Encoding
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func contentEncoding(_ algorithm: CompressionAlgorithm?) -> Self {
        contentEncoding = algorithm
        return self
    }
}

// MARK: Content-Length
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func contentLength(_ length: Int?) -> Self {
        contentLength = length
        return self
    }
}

// MARK: Content-Type
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func contentType(_ contentType: HTTPMediaType?) -> Self {
        self.contentType = contentType?.httpValue
        return self
    }

    @discardableResult
    @inlinable
    mutating func contentType<T: HTTPMediaTypeProtocol>(_ contentType: T?) -> Self {
        self.contentType = contentType?.httpValue
        return self
    }
}

// MARK: Retry-After
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func retryAfter(_ seconds: Int?) -> Self {
        retryAfterDuration = seconds
        return self
    }

    #if canImport(FoundationEssentials)
    @discardableResult
    @inlinable
    mutating func retryAfter(_ date: Date?) -> Self {
        retryAfterDate = date
        return self
    }
    #endif
}

// MARK: TK
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func tk(_ tk: HTTPResponseHeader.TK?) -> Self {
        self.tk = tk
        return self
    }
}

// MARK: X-Content-Type-Options
public extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    mutating func xContentTypeOptions(_ nosniff: Bool) -> Self {
        xContentTypeOptions = nosniff
        return self
    }
}