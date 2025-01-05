//
//  RequestProtocol.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import HTTPTypes

/// Core Request protocol that lays out how a socket's incoming data is parsed.
public protocol RequestProtocol : Sendable, ~Copyable {
    //associatedtype Storage : RequestStorageProtocol
    //associatedtype Headers : HTTPHeadersProtocol

    init?(tokens: [SIMD64<UInt8>])

    //var storage : Storage { get set }

    /// The HTTP start-line.
    var startLine : DestinyRoutePathType { get }

    /// The optional request method.
    var method : HTTPRequest.Method? { mutating get }

    /// The endpoint the request wants to reach, separated by the forward slash character.
    var path : [String] { mutating get }
    
    /// The request headers.
    var headers : any HTTPHeadersProtocol { mutating get }
}

/*
/// Core Request Storage protocol that lays out how data for a request is stored.
/// 
/// Some examples of data that is usually stored include:
/// - Authentication headers
/// - Cookies
/// - Unique IDs
public protocol RequestStorageProtocol : Sendable, ~Copyable {
    /// - Returns: The stored value for the associated key.
    func get<K, V>(key: K) -> V?
    /// Stores the value for the associated key.
    func set<K, V>(key: K, value: V?)
}*/