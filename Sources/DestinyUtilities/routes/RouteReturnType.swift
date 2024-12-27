//
//  RouteReturnType.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

public struct RouteReturnType : Sendable {
    @inlinable
    public static func bytes<T: FixedWidthInteger>(_ bytes: [T]) -> String {
        return "[" + bytes.map({ "\($0)" }).joined(separator: ",") + "]"
    }
    private static func response(valueType: String, _ string: String) -> String {
        return "RouteResponses." + valueType + "(" + string + ")"
    }
    
    /// - Returns: The encoded string is a `StaticString`.
    public static let staticString:RouteReturnType = RouteReturnType(
        rawValue: "staticString",
        encode: { $0 },
        debugDescription: { response(valueType: "StaticString", "\"" + $0 + "\"") }
    )

    /// - Returns: The encoded string as a `[UInt8]`.
    public static let uint8Array:RouteReturnType = RouteReturnType(
        rawValue: "uint8Array",
        encode: { bytes([UInt8]($0.utf8)) },
        debugDescription: { response(valueType: "UInt8Array", bytes([UInt8]($0.utf8))) }
    )

    /// - Returns: The encoded string as a `[UInt16]`.
    public static let uint16Array:RouteReturnType = RouteReturnType(
        rawValue: "uint16Array",
        encode: { bytes([UInt16]($0.utf16)) },
        debugDescription: { response(valueType: "UInt16Array", bytes([UInt16]($0.utf16))) }
    )

    /// - Returns: The encoded string as a Foundation `Data`.
    public static let data:RouteReturnType = RouteReturnType(
        rawValue: "data",
        encode: { "Data(" + bytes([UInt8]($0.utf8)) + ")" },
        debugDescription: { response(valueType: "Data", bytes([UInt8]($0.utf8))) }
    )
    /*public static let unsafeBufferPointer:RouteReturnType = RouteReturnType(
        rawValue: "unsafeBufferPointer",
        debugDescription: { response(valueType: "UnsafeBufferPointer", "StaticString(\"" + $0 + "\").withUTF8Buffer { $0 }") }
    )*/

    //public static var custom:[String:RouteReturnType] = [:]
    
    /// The identifier for this route return type.
    public let rawValue:String

    /// - Returns: The encoded result.
    public let encode:@Sendable (String) -> String
    
    /// - Returns: The debugDescription of the route responder for the input result.
    public let debugDescription:@Sendable (String) -> String

    public init(rawValue: String, encode: @escaping @Sendable (String) -> String, debugDescription: @escaping @Sendable (String) -> String) {
        self.rawValue = rawValue
        self.encode = encode
        self.debugDescription = debugDescription
    }
    public init?(rawValue: String) {
        switch rawValue {
        case "staticString":        self = .staticString
        case "uint8Array":          self = .uint8Array
        case "uint16Array":         self = .uint16Array
        case "data":                self = .data
        //case "unsafeBufferPointer": self = .unsafeBufferPointer
        default:
            return nil
            /*guard let target:RouteReturnType = Self.custom[rawValue] else { return nil }
            self = target*/
        }
    }
}