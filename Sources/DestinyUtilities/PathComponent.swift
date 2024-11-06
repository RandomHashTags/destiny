//
//  PathComponent.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

public enum PathComponent : CustomStringConvertible, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    case literal(String)
    case parameter(String)

    public init(stringLiteral value: String) {
        if value.first == ":" {
            self = .parameter(String(value[value.index(after: value.startIndex)...]))
        } else {
            self = .literal(value)
        }
    }

    public var description : String {
        switch self {
            case .literal(let value):   return "\"" + value + "\""
            case .parameter(let value): return "\":" + value + "\""
        }
    }

    public var isParameter : Bool {
        switch self {
            case .literal(_):   return false
            case .parameter(_): return true
        }
    }

    public var value : String {
        switch self {
            case .literal(let value):   return value
            case .parameter(let value): return value
        }
    }
}