//
//  HTTPHeaders.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

import DestinyUtilities

/// The default storage for HTTP headers.
public struct HTTPHeaders : HTTPHeadersProtocol, Sendable { // TODO: make SIMD
    public typealias Key = String
    public typealias Value = String

    @usableFromInline var storage:[String:String] = [:]

    public init(_ storage: [String:String] = [:]) {
        self.storage = storage
    }

    @inlinable
    public subscript(_ header: Key) -> Value? {
        get {
            return storage[header]
        }
        set {
            storage[header] = newValue
        }
    }

    @inlinable public func has(_ header: Key) -> Bool {
        return storage[header] != nil
    }

    @inlinable
    public mutating func add(_ value: String, header: String) {
        if let existingValue:String = storage[header] {
            storage[header] = existingValue + "," + value
        } else {
            storage[header] = value
        }
    }
}