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
        var value:[DeclSyntax] = [
            equatable(amount: integer),
            "public typealias BufferType = (\(raw: buffer))",
            "public var buffer:BufferType",
            "public init() { buffer = (\(raw: zeros)) }",
            "public init(buffer: BufferType) { self.buffer = buffer }",
            hashable(amount: integer),
            get_set_index(amount: integer)
        ]
        /*for i in 1..<integer {
            value.append(get_fixed_size_init(limit: integer, amount: i))
        }*/
        value.append("public var size : Int { \(raw: integer) }")
        return value
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
    static func get_set_index(amount: Int) -> DeclSyntax {
        var string:String = "public mutating func set(index: Int, char: CChar) {"
        string += "guard index < size else { return }"
        string += "switch index {"
        for i in 0..<amount {
            string += "case \(i): buffer.\(i) = char break "
        }
        string += "default: break"
        string += "} }"
        return "\(raw: string)"
    }
}

struct Test {
    static let size:Int = 8
    typealias ByteBuffer = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    var buffer:ByteBuffer
    init(_ characters: CChar...) {
        self.buffer = (0, 0, 0, 0, 0, 0, 0, 0)
        for (index, char) in characters.enumerated() {
            set(index: index, char: char)
        }
    }

    mutating func set(index: Int, char: CChar) {
        guard index < Self.size else { return }
        switch index {
            case 0:
                buffer.0 = char
                break
            default:
                break
        }
    }
}