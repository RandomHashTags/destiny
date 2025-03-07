//
//  HTTPResponseHeadersProtocol.swift
//
//
//  Created by Evan Anderson on 3/7/25.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import SwiftCompression

public protocol HTTPResponseHeadersProtocol : HTTPHeadersProtocol {
    var allow : String? { get }
    var age : Int? { get }
    var contentLength : Int? { get }
    var retryAfterDuration : Int? { get }
    var contentType : String? { get }

    #if canImport(FoundationEssentials) || canImport(Foundation)
    var retryAfterDate : Date? { get }
    #endif

    var xContentTypeOptions : Bool { get }

    var acceptRanges : HTTPResponseHeader.AcceptRanges? { get }
    var contentEncoding : CompressionAlgorithm? { get }
    var tk : HTTPResponseHeader.TK? { get }

    @inlinable mutating func merge<T: HTTPResponseHeadersProtocol>(_ headers: T)
}