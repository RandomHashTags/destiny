//
//  Charset.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

import SwiftSyntax

// MARK: Charset
/// HTTP charset encodings.
public enum Charset : String, CustomDebugStringConvertible, Sendable {
    case any
    case basicMultilingualPlane
    case bocu1
    case iso8859_5
    case scsu
    case ucs2
    case ucs4
    case utf8
    case utf16
    case utf16be
    case utf16le
    case utf32

    // MARK: Debug description
    @inlinable
    public var debugDescription : String {
        "Charset.\(rawValue)"
    }

    // MARK: Raw name
    @inlinable
    public var rawName : String {
        switch self {
        case .any: return "*"
        case .basicMultilingualPlane: return "BMP"
        case .bocu1: return "BOCU-1"
        case .iso8859_5: return "ISO-8859-5"
        case .scsu: return "SCSU"
        case .ucs2: return "UCS-2"
        case .ucs4: return "UCS-4"
        case .utf8: return "UTF-8"
        case .utf16: return "UTF-16"
        case .utf16be: return "UTF-16BE"
        case .utf16le: return "UTF-16LE"
        case .utf32: return "UTF-32"
        }
    }
}

#if canImport(SwiftSyntax)
/// MARK: SwiftSyntax
extension Charset {
    public init?(expr: ExprSyntax) {
        guard let string:String = expr.memberAccess?.declName.baseName.text ?? expr.stringLiteral?.string.lowercased() else {
            return nil
        }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            switch string {
            case "bocu-1": self = .bocu1
            case "iso-8859-5": self = .iso8859_5
            case "ucs-2": self = .ucs2
            case "ucs-4": self = .ucs4
            case "utf-8": self = .utf8
            case "utf-16": self = .utf16
            case "utf-16be": self = .utf16be
            case "utf-16le": self  = .utf16le
            case "utf-32": self = .utf32
            default: return nil
            }
        }
    }
}
#endif