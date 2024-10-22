//
//  StackString.swift
//
//
//  Created by Evan Anderson on 10/21/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct StackString : MemberMacro { // TODO: create concrete SIMD types instead of using this macro
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let integer:Int = Int(node.arguments!.children(viewMode: .all).first!.as(LabeledExprSyntax.self)!.expression.as(IntegerLiteralExprSyntax.self)!.literal.text)!
        let range:Range<Int> = 0..<integer
        let buffer:String = range.map({ _ in "UInt8" }).joined(separator: ",")
        let zeros:String = range.map({ _ in "0" }).joined(separator: ",")
        return [
            equatable(amount: integer),
            "/// The number of bytes this StackString contains.",
            "public static var size : Int { \(raw: integer) }",
            "/// This StackString's byte buffer with zero assigned at every value.",
            "public static let zeroBuffer:(\(raw: buffer)) = (\(raw: zeros))",
            "public typealias BufferType = (\(raw: buffer))",
            "public var buffer:BufferType",
            "public init() { buffer = Self.zeroBuffer }",
            "public init(_ buffer: BufferType) { self.buffer = buffer }",
            "public init(_ characters: UInt8...) { self.buffer = Self.zeroBuffer let length:Int = min(Self.size, characters.count) var index:Int = 0 while index < length { self[index] = characters[index] index += 1 } }",
            get_string_init(amount: integer),
            get_description(amount: integer),
            get_subscript(amount: integer),
            get_split_logic(amount: integer),
            get_count(),
            get_has_prefix(),
            hashable(amount: integer),
        ]
    }
    // MARK: Equatable
    static func equatable(amount: Int) -> DeclSyntax {
        var string:String = "public static func == (left: Self, right: Self) -> Bool {"
        string += "if "
        for i in 0..<amount {
            string += (i == 0 ? "" : " || ") + "left.buffer.\(i) != right.buffer.\(i)"
        }
        string += "{ return false }"
        string += "return true "
        string += "}"
        return "\(raw: string)"
    }
    // MARK: Hashable
    static func hashable(amount: Int) -> DeclSyntax {
        var string:String = "public func hash(into hasher: inout Hasher) {"
        for i in 0..<amount {
            string += "hasher.combine(buffer.\(i)) "
        }
        string += "}"
        return "\(raw: string)"
    }
    // MARK: Subscript
    static func get_subscript(amount: Int) -> DeclSyntax {
        var string:String = "public subscript(_ index: Int) -> UInt8 {"
        func thing(_ i: Int, logic: String) -> String {
            return "case \(i): " + logic + " "
        }
        var get_string:String = "get { switch index {"
        for i in 0..<amount {
            get_string += thing(i, logic: "return buffer.\(i)")
        }
        get_string += "default: return 0 } }"
        string += get_string

        var set_string:String = "set { switch index {"
        for i in 0..<amount {
            set_string += thing(i, logic: "buffer.\(i) = newValue break")
        }
        set_string += "default: break } }"
        string += set_string

        string += "}"
        return "\(raw: string)"
    }
    // MARK: Split
    static func get_split_logic(amount: Int) -> DeclSyntax {
        var string:String = "/// Split this StackString based on a separator.\n"
        string += "public func split(separator: UInt8) -> [Self] {"
        string += "var anchor:Int = 0, array:[Self] = [] "
        string += "array.reserveCapacity(2)"
        string += "for i in 0..<Self.size {"
            string += "if self[i] == separator {"
                string += "var slice:Self = Self(), slice_index:Int = 0 "
                string += "if anchor != 0 { anchor += 1 }"
                string += "if anchor < i {"
                    string += "for j in anchor..<i { slice[slice_index] = self[anchor + j] slice_index += 1 }"
                    string += "if slice_index != 0 { array.append(slice) } "
                    string += "anchor = i"
                string += "}"
            string += "}"
        string += "}"
        string += "if array.isEmpty { return [self] }"
        string += "var ending_slice:Self = Self(), slice_index:Int = 0 "
        string += "if anchor != 0 { anchor += 1 }"
        string += "for i in anchor..<Self.size { ending_slice[slice_index] = self[i] slice_index += 1 }"
        string += "array.append(ending_slice)"
        string += "return array }"
        return "\(raw: string)"
    }
    // MARK: Description
    static func get_description(amount: Int) -> DeclSyntax {
        var string:String = "public var description : String { "
        string += "\""
        for i in 0..<amount {
            string += "\\(Character(Unicode.Scalar(buffer.\(i))))"
        }
        string += "\" }"
        return "\(raw: string)"
    }
    // MARK: Init from string
    static func get_string_init(amount: Int) -> DeclSyntax {
        var string:String = "public init(_ string: inout String) {"
            string += "var buffer:BufferType = Self.zeroBuffer "
            string += "string.withUTF8 { p in "
                string += "if p.count < \(amount) {"
                    string += "var a:Self = Self() "
                    string += "for i in 0..<p.count {"
                        string += "a[i] = p[i]"
                    string += "}"
                    string += "buffer = a.buffer"
                string += "} else { "
                    string += " buffer = ("
                    for i in 0..<amount {
                        string += (i == 0 ? "" : ", ") + "p[\(i)]"
                    }
                    string += ")"
                string += "}"
            string += "}"
        string += " self.buffer = buffer }"
        return "\(raw: string)"
    }
    // MARK: Get count
    static func get_count() -> DeclSyntax {
        var string:String = "/// The number of non-zero leading bytes this StackString has.\n"
        string += "/// - Complexity: O(_n_) where _n_ is this StackString's size.\n"
        string += "public var count : Int {"
            string += "for i in 0..<Self.size {"
                string += "if self[i] == 0 { return i }"
            string += "}"
        string += "return Self.size }"
        return "\(raw: string)"
    }
    // MARK: Has prefix
    static func get_has_prefix() -> DeclSyntax {
        var string:String = "/// Whether or not this StackString is prefixed with the given `StackStringProtocol`.\n"
        string += "/// - Complexity: O(_n_) where _n_ equals the lesser count of the two.\n"
        string += "public func hasPrefix<T : StackStringProtocol>(_ string: T) -> Bool {"
        string += "let length:Int = min(string.count, self.count)"
        string += "for i in 0..<length {"
            string += "if self[i] != string[i] { return false }"
        string += "}"
        string += "return true }"
        return "\(raw: string)"
    }
    static func get_has_string_prefix() -> DeclSyntax {
        var string:String = "public func hasPrefix(_ string: String) -> Bool {"
        string += "}"
        return "\(raw: string)"
    }
}

// MARK: Test
struct Test {
    func test_simd(left: SIMD64<UInt8>, right: SIMD64<UInt8>) -> Bool {
        return left == right
    }
    static var size : Int { 8 } 
    typealias ByteBuffer = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    var buffer:ByteBuffer

    subscript(_ index: Int) -> UInt8 {
        get {
            switch index {
                case 0: return buffer.0
                default: return 0
            }
        }
        set {
            buffer.0 = newValue
        }
        
    }

    init(string: inout String) {
        var buffer:ByteBuffer = (0, 0, 0, 0, 0, 0, 0,0)
        string.withUTF8 { p in
            let length:Int = min(8, p.count)
            switch length {
                case 0: break
                case 1:
                    buffer.0 = p[0]
                    break
                default:
                    break
            }
        }
        self.buffer = buffer
    }

    init(_ characters: UInt8...) {
        buffer = (characters[0], characters[1], characters[2], characters[3], characters[4], characters[5], characters[6], characters[7])
    }

    mutating func set(index: Int, char: UInt8) {
        self[index] = char
    }

    var simd : SIMD8<UInt8> {
        SIMD8<UInt8>(buffer.0, buffer.1, buffer.2, buffer.3, buffer.4, buffer.5, buffer.6, buffer.7)
    }
}