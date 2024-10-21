//
//  StackString.swift
//
//
//  Created by Evan Anderson on 10/21/24.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

import Foundation

struct StackString : MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let integer:Int = Int(node.arguments!.children(viewMode: .all).first!.as(LabeledExprSyntax.self)!.expression.as(IntegerLiteralExprSyntax.self)!.literal.text)!
        let range:Range<Int> = 0..<integer
        let buffer:String = range.map({ _ in "UInt8" }).joined(separator: ",")
        let zeros:String = range.map({ _ in "0" }).joined(separator: ",")
        return [
            equatable(amount: integer),
            "public typealias BufferType = (\(raw: buffer))",
            "public var buffer:BufferType",
            "public init() { buffer = (\(raw: zeros)) }",
            "public init(buffer: BufferType) { self.buffer = buffer }",
            "public init(characters: UInt8...) { self.buffer = (\(raw: zeros)) let length:Int = min(size, characters.count) var index:Int = 0 while index < length { self[index] = characters[index] index += 1 } }",
            "public var size : Int { \(raw: integer) }",
            get_description(amount: integer),
            get_subscript(amount: integer),
            get_split_logic(amount: integer),
            hashable(amount: integer),
        ]
    }
    static func equatable(amount: Int) -> DeclSyntax {
        var string:String = "public static func == (left: Self, right: Self) -> Bool {"
        string += "if "
        for i in 0..<amount {
            string += (i == 0 ? "" : " || ") + "left.buffer.\(i) != right.buffer.\(i)"
        }
        string += "{ return false }"
        string += "return true }"
        return "\(raw: string)"
    }
    static func hashable(amount: Int) -> DeclSyntax {
        var string:String = "public func hash(into hasher: inout Hasher) {"
        for i in 0..<amount {
            string += "hasher.combine(buffer.\(i)) "
        }
        string += "}"
        return "\(raw: string)"
    }
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
    static func get_split_logic(amount: Int) -> DeclSyntax {
        var string:String = "public func split(separator: UInt8) -> [Self] {"
        string += "var anchor:Int = 0, array:[Self] = [] "
        string += "array.reserveCapacity(2)"
        string += "for i in 0..<size {"
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
        string += "for i in anchor..<size { ending_slice[slice_index] = self[i] slice_index += 1 }"
        string += "array.append(ending_slice)"
        string += "return array }"
        return "\(raw: string)"
    }
    static func get_description(amount: Int) -> DeclSyntax {
        var string:String = "public var description : String {"
        for i in 0..<amount {
            string += (i == 0 ? "" : " + ") + "String(describing: Character(Unicode.Scalar(buffer.\(i))))"
        }
        string += "}"
        return "\(raw: string)"
    }
}

struct Test {
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

    mutating func set(index: Int, char: UInt8) {
        self[index] = char
    }
}