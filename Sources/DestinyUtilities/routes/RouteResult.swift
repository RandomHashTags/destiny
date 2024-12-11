//
//  RouteResult.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import Foundation

public enum RouteResult : Sendable {
    case string(String)
    case bytes([UInt8])
    case json(Encodable & Sendable)
    case error(Error)

    public var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
            case .json(let encodable): return (try? JSONEncoder().encode(encodable).count) ?? 0
            case .error(let error): return "\(error)".count
        }
    }

    @inlinable
    package func string() throws -> String {
        switch self {
            case .string(let string): return string
            case .bytes(let bytes): return bytes.map({ "\($0)" }).joined()
            case .json(let encodable):
                do {
                    let data:Data = try JSONEncoder().encode(encodable)
                    return String(data: data, encoding: .utf8) ?? "{\"error\":500\",\"reason\":\"couldn't convert JSON encoded Data to UTF-8 String\"}"
                } catch {
                    return "{\"error\":500,\"reason\":\"\(error)\"}"
                }
            case .error(let error): return "\(error)"
        }
    }
}