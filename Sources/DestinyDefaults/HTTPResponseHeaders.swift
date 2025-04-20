//
//  HTTPResponseHeaders.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint
import DestinyUtilities
import SwiftCompression

// MARK: HTTPResponseHeaders
/// Default storage for HTTP response headers.
public struct HTTPResponseHeaders : HTTPResponseHeadersProtocol { // TODO: finish
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

    #if canImport(FoundationEssentials) || canImport(Foundation)
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
extension HTTPResponseHeaders {
    @inlinable
    public mutating func acceptRanges(_ ranges: HTTPResponseHeader.AcceptRanges?) -> Self {
        acceptRanges = ranges
        return self
    }
}

// MARK: Age
extension HTTPResponseHeaders {
    @inlinable
    public mutating func age(_ age: Int?) -> Self {
        self.age = age
        return self
    }
}

// MARK: Allow
extension HTTPResponseHeaders {
    @inlinable
    public mutating func allow<C: Collection<HTTPRequestMethod>>(_ methods: C?) -> Self {
        var temp = ""
        if let methods {
            var has = false
            for method in methods {
                if has {
                    temp += ", "
                }
                temp.append(method.rawName)
                has = true
            }
        }
        allow = temp
        return self
    }
}

// MARK: Content-Encoding
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func contentEncoding(_ algorithm: CompressionAlgorithm?) -> Self {
        contentEncoding = algorithm
        return self
    }
}

// MARK: Content-Length
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func contentLength(_ length: Int?) -> Self {
        contentLength = length
        return self
    }
}

// MARK: Content-Type
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func contentType(_ contentType: HTTPMediaType?) -> Self {
        if let contentType {
            self.contentType = "\(contentType)"
        } else {
            self.contentType = nil
        }
        return self
    }
}

// MARK: Retry-After
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func retryAfter(_ seconds: Int?) -> Self {
        retryAfterDuration = seconds
        return self
    }

    #if canImport(FoundationEssentials) || canImport(Foundation)
    @discardableResult
    @inlinable
    public mutating func retryAfter(_ date: Date?) -> Self {
        retryAfterDate = date
        return self
    }
    #endif
}

// MARK: TK
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func tk(_ tk: HTTPResponseHeader.TK?) -> Self {
        self.tk = tk
        return self
    }
}

// MARK: X-Content-Type-Options
extension HTTPResponseHeaders {
    @discardableResult
    @inlinable
    public mutating func xContentTypeOptions(_ nosniff: Bool) -> Self {
        xContentTypeOptions = nosniff
        return self
    }
}