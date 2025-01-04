//
//  HTTPFieldContentType.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPFieldContentType : DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var cases:[String] = []
        var httpValues:[String] = []
        var category:String = ""
        for argument in node.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                switch child.label!.text {
                    case "category": category = child.expression.stringLiteral!.string
                    case "values": parse_and_insert(category: category, expr: child.expression, cases: &cases, httpValues: &httpValues)
                    default: break
                }
            }
        }
        let categoryCapitalized:String = category[category.startIndex].uppercased() + String(category[category.index(after: category.startIndex)...])
        var cases_string:String = ""
        var debugDescriptions:String = "        // MARK: DebugDescription\n        public var debugDescription : String {\n            switch self {"
        var httpValuesString:String = "        // MARK: HTTP Value\n        public var httpValue : String {\n            switch self {"
        var decls:[DeclSyntax] = []
        for (index, value) in cases.enumerated() {
            cases_string += "        case \(value)\n"
            debugDescriptions += "\ncase .\(value): return \"HTTPMediaTypes.\(categoryCapitalized).\(value)\""
            httpValuesString += "\ncase .\(value): return \"\(httpValues[index])\""
        }
        debugDescriptions += "}\n        }"
        httpValuesString += "}\n        }"
        decls.append("\(raw: "enum \(categoryCapitalized) : String, HTTPMediaTypeProtocol {\n")")
        decls.append("\(raw: cases_string)")
        decls.append("\(raw: debugDescriptions)")
        decls.append("\(raw: httpValuesString)")
        decls.append("\(raw: "\n    }")")
        return decls
    }
    static func parse_and_insert(
        category: String,
        expr: ExprSyntax,
        cases: inout [String],
        httpValues: inout [String]
    ) {
        guard let dictionary:DictionaryElementListSyntax = expr.dictionary?.content.as(DictionaryElementListSyntax.self) else { return }
        httpValues = []
        for element in dictionary {
            let key:String = element.key.stringLiteral!.string
            var value:String = element.value.stringLiteral!.string
            if value.isEmpty {
                value = key
            }
            cases.append(key)
            httpValues.append(category + "/" + value)
        }
    }
}