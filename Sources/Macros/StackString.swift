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
            hashable(amount: integer)
        ]
        for i in 1..<integer {
            value.append(get_fixed_size_init(limit: integer, amount: i))
        }
        value.append("public var size : Int { \(raw: integer) }")
        return value
    }
    static func equatable(amount: Int) -> DeclSyntax {
        var string:String = "public static func == (left: Self, right: Self) -> Bool {"
        string += "for i in 0..<\(amount) {"
        for i in 0..<amount {
            string += "if left.buffer.\(i) != right.buffer.\(i) { return false }"
        }
        string += "} return true }"
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
    static func get_fixed_size_init(limit: Int, amount: Int) -> DeclSyntax {
        let range:Range<Int> = 0..<amount
        let assigned:String = range.map({ amount == 1 && $0 == 0 ? "buffer" : "buffer.\($0)" }).joined(separator: ",")
        let missing:String = (amount..<limit).map({ _ in "0" }).joined(separator: ",")
        return "public init(buffer: (\(raw: range.map({ _ in "CChar" }).joined(separator: ",")))) { self.buffer = (\(raw: assigned), \(raw: missing)) }"
    }
}