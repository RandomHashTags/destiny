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
        let buffer:String = range.map({ _ in "CChar" }).joined(separator: ",")
        let zeros:String = range.map({ _ in "0" }).joined(separator: ",")
        return [
            equatable(amount: integer),
            "public typealias BufferType = (\(raw: buffer))",
            "public var buffer:BufferType",
            "public var size : Int { \(raw: integer) }",
            "public init() { buffer = (\(raw: zeros)) }",
            "public init(buffer: BufferType) { self.buffer = buffer }",
            "public init(characters: CChar...) { self.buffer = (\(raw: zeros)) let length:Int = min(size, characters.count) var index:Int = 0 while index < length { self[index] = characters[index] index += 1 } }",
            get_subscript(amount: integer),
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
        var string:String = "public subscript(_ index: Int) -> CChar {"
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
        var string:String = "public func split(separator: CChar) -> [Self] {"
        string += "var anchor:Int = 0, array:[Self] = []"
        string += "for i in 0..<size {"
        string += "if buffer[i] == separator {"
        string += "anchor = i"
        string += "}"
        string += "} return array }"
        return "\(raw: string)"
    }
}

struct Test {
    typealias ByteBuffer = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    var buffer:ByteBuffer

    subscript(_ index: Int) -> CChar {
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

    mutating func set(index: Int, char: CChar) {
        self[index] = char
    }
}