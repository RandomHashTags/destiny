//
//  HTTPRequestHeadersProtocol.swift
//
//
//  Created by Evan Anderson on 3/7/25.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

public protocol HTTPRequestHeadersProtocol : HTTPHeadersProtocol {
    var accept : String? { get }
    var acceptCharset : Charset? { get }

    #if canImport(FoundationEssentials) || canImport(Foundation)
    var acceptDatetime : Date? { get }
    #endif

    var acceptEncoding : HTTPRequestHeader.AcceptEncoding? { get }
    var contentLength : Int? { get }
    var contentType : String? { get }

    #if canImport(FoundationEssentials) || canImport(Foundation)
    var date : Date? { get }
    #endif

    var from : String? { get }
    var host : String? { get }
    var maxForwards : Int? { get }
    var range : HTTPRequestHeader.Range? { get }

    var upgradeInsecureRequests : Bool { get }
    var xRequestedWith : HTTPRequestHeader.XRequestedWith? { get }
    var dnt : Bool? { get }
    //var xHttpMethodOverride : (any HTTPRequestMethodProtocol)? { get }
    var secGPC : Bool { get }

    @inlinable mutating func merge<T: HTTPRequestHeadersProtocol>(_ headers: T)
}