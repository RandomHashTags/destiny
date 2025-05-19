//
//  Charset.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

import SwiftSyntax

// MARK: Charset
/// HTTP charset encodings.
public enum Charset: String, CustomDebugStringConvertible, Sendable {
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
    public var debugDescription: String {
        "Charset.\(rawValue)"
    }

    // MARK: Raw name
    @inlinable
    public var rawName: String {
        switch self {
        case .any: "*"
        case .basicMultilingualPlane: "BMP"
        case .bocu1: "BOCU-1"
        case .iso8859_5: "ISO-8859-5"
        case .scsu: "SCSU"
        case .ucs2: "UCS-2"
        case .ucs4: "UCS-4"
        case .utf8: "UTF-8"
        case .utf16: "UTF-16"
        case .utf16be: "UTF-16BE"
        case .utf16le: "UTF-16LE"
        case .utf32: "UTF-32"
        }
    }
}

#if canImport(SwiftSyntax)
/// MARK: SwiftSyntax
extension Charset {
    public init?(expr: ExprSyntax) {
        guard let string = expr.memberAccess?.declName.baseName.text ?? expr.stringLiteral?.string.lowercased() else {
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