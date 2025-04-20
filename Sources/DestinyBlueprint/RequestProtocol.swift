//
//  RequestProtocol.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

/// Core Request protocol that lays out how a socket's incoming data is parsed.
public protocol RequestProtocol : Sendable, ~Copyable {
    associatedtype ConcreteHTTPRequestMethod:HTTPRequestMethodProtocol
    associatedtype ConcreteHTTPRequestHeaders:HTTPRequestHeadersProtocol

    /// Initializes the bare minimum data required to process a socket's data.
    init?<T: SocketProtocol & ~Copyable>(socket: borrowing T) throws

    /// The HTTP start-line.
    var startLine : SIMD64<UInt8> { get }

    /// The optional request method.
    var method : ConcreteHTTPRequestMethod? { mutating get }

    /// The endpoint the request wants to reach, separated by the forward slash character.
    var path : [String] { mutating get }
    
    /// The request headers.
    var headers : ConcreteHTTPRequestHeaders { mutating get }
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