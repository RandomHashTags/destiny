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

import DestinyUtilities
import SwiftCompression

// MARK: HTTPResponseHeaders
/// Default storage for HTTP response headers.
public struct HTTPResponseHeaders : HTTPHeadersProtocol { // TODO: finish
    public typealias Key = String
    public typealias Value = String

    public var custom:[Key:Value] = [:]

    public var allow:String?
    public var age:Int?
    public var contentLength:Int?
    public var retryAfterDuration:Int?
    public var contentType:String?

    #if canImport(FoundationEssentials) || canImport(Foundation)
    public var retryAfterDate:Date?
    #endif

    public var xContentTypeOptions:Bool = false

    public var acceptRanges:HTTPResponseHeader.AcceptRanges?
    public var contentEncoding:CompressionAlgorithm?
    public var tk:HTTPResponseHeader.TK?
    
    public init() {
    }
    public init(
        acceptRanges: HTTPResponseHeader.AcceptRanges? = nil,
        age: Int? = nil,
        allow: String? = nil,
        contentEncoding: CompressionAlgorithm? = nil,
        contentLength: Int? = nil,
        contentType: String? = nil,
        retryAfterDuration: Int? = nil,
        tk: HTTPResponseHeader.TK? = nil,
        xContentTypeOptions: Bool = false,
        custom: [String:String] = [:]
    ) {
        self.acceptRanges = acceptRanges
        self.age = age
        self.allow = allow
        self.contentEncoding = contentEncoding
        self.contentLength = contentLength
        self.contentType = contentType
        self.retryAfterDuration = retryAfterDuration
        self.tk = tk
        self.xContentTypeOptions = xContentTypeOptions
        self.custom = custom
    }

    @inlinable
    public subscript(_ header: Key) -> Value? {
        get { custom[header] }
        set { custom[header] = newValue }
    }

    @inlinable
    public subscript(_ header: Key, default defaultValue: @autoclosure () -> Key) -> Value {
        get { custom[header, default: defaultValue()] }
        set { custom[header] = newValue }
    }

    @inlinable
    public func has(_ header: Key) -> Bool {
        return custom[header] != nil
    }
}

// MARK: Merge
extension HTTPResponseHeaders {
    @inlinable
    public mutating func merge(_ headers: Self) {
        if let v = headers.acceptRanges { acceptRanges = v }
        if let v = headers.age { age = v }
        if let v = headers.allow { allow = v }
        if let v = headers.contentEncoding { contentEncoding = v }
        if let v = headers.contentLength { contentLength = v }
        if let v = headers.contentType { contentType = v }
        if let v = headers.retryAfterDuration { retryAfterDuration = v }

        #if canImport(FoundationEssentials) || canImport(Foundation)
        if let v = headers.retryAfterDate { retryAfterDate = v }
        #endif

        if let v = headers.tk { tk = v }
        xContentTypeOptions = headers.xContentTypeOptions
        for (key, value) in headers.custom {
            custom[key] = value
        }
    }
}

// MARK: Iterate
extension HTTPResponseHeaders {
    @inlinable
    public func iterate(yield: (Key, Value) -> Void) {
        if let acceptRanges { yield(HTTPResponseHeader.acceptRanges.rawName, acceptRanges.rawValue) }
        if let age { yield(HTTPResponseHeader.age.rawName, "\(age)") }
        if let allow { yield(HTTPResponseHeader.allow.rawName, allow) }
        if let contentEncoding { yield(HTTPResponseHeader.contentEncoding.rawName, contentEncoding.rawValue) } // TODO: fix
        if let contentLength { yield(HTTPResponseHeader.contentLength.rawName, "\(contentLength)") }
        if let contentType { yield(HTTPResponseHeader.contentType.rawName, contentType) }
        if let retryAfterDuration { yield(HTTPResponseHeader.retryAfter.rawName, "\(retryAfterDuration)") }

        #if canImport(FoundationEssentials) || canImport(Foundation)
        if let retryAfterDate { yield(HTTPResponseHeader.retryAfter.rawName, retryAfterDate.debugDescription) } // TODO: fix
        #endif

        if let tk { yield(HTTPResponseHeader.tk.rawName, tk.rawValue) }
        if xContentTypeOptions { yield(HTTPResponseHeader.xContentTypeOptions.rawName, "true") }
        for (key, value) in custom {
            yield(key, value)
        }
    }
}

// MARK: DebugDescription
extension HTTPResponseHeaders {
    public var debugDescription : String {
        var values:[String] = []
        if let acceptRanges { values.append("acceptRanges: \(acceptRanges)") }
        if let age { values.append("age: \(age)") }
        if let allow { values.append("allow: \"\(allow)\"") }
        if let contentEncoding { values.append("contentEncoding: .\(contentEncoding)") }
        if let contentLength { values.append("contentLength: \(contentLength)") }
        if let contentType { values.append("contentType: \"\(contentType)\"") }
        if let retryAfterDuration { values.append("retryAfterDuration: \(retryAfterDuration)") }

        #if canImport(FoundationEssentials) || canImport(Foundation)
        if let retryAfterDate { values.append("retryAfterDate: \(retryAfterDate.debugDescription)") } // TODO: fix
        #endif

        if !custom.isEmpty {
            values.append("custom: \(custom)")
        }
        return "HTTPResponseHeaders(\(values.joined(separator: ",")))"
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
        self.contentType = contentType?.description
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