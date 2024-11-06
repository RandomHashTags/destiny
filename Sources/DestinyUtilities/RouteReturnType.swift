//
//  RouteReturnType.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

public struct RouteReturnType : Sendable {
    public static func bytes<T: FixedWidthInteger>(_ bytes: [T]) -> String {
        return "[" + bytes.map({ "\($0)" }).joined(separator: ",") + "]"
    }
    private static func response(valueType: String, _ string: String) -> String {
        return "RouteResponses." + valueType + "(" + string + ")"
    }
    
    public static let staticString:RouteReturnType = RouteReturnType(
        rawValue: "staticString",
        encode: { response(valueType: "StaticString", "\"" + $0 + "\"") }
    )
    public static let uint8Array:RouteReturnType = RouteReturnType(
        rawValue: "uint8Array",
        encode: { response(valueType: "UInt8Array", bytes([UInt8]($0.utf8))) }
    )
    public static let uint16Array:RouteReturnType = RouteReturnType(
        rawValue: "uint16Array",
        encode: { response(valueType: "UInt16Array", bytes([UInt16]($0.utf16))) }
    )
    public static let data:RouteReturnType = RouteReturnType(
        rawValue: "data",
        encode: { response(valueType: "Data", bytes([UInt8]($0.utf8))) }
    )
    public static let unsafeBufferPointer:RouteReturnType = RouteReturnType(
        rawValue: "unsafeBufferPointer",
        encode: { response(valueType: "UnsafeBufferPointer", "StaticString(\"" + $0 + "\").withUTF8Buffer { $0 }") }
    )

    public static var custom:[String:RouteReturnType] = [:]
    
    public let rawValue:String
    public let encode:@Sendable (String) -> String

    public init(rawValue: String, encode: @escaping @Sendable (String) -> String) {
        self.rawValue = rawValue
        self.encode = encode
    }
    public init?(rawValue: String) {
        switch rawValue {
            case "staticString":        self = .staticString
            case "uint8Array":          self = .uint8Array
            case "uint16Array":         self = .uint16Array
            case "data":                self = .data
            case "unsafeBufferPointer": self = .unsafeBufferPointer
            default:
                guard let target:RouteReturnType = Self.custom[rawValue] else { return nil }
                self = target
        }
    }
}