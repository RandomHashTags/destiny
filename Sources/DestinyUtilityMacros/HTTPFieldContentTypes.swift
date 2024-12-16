//
//  HTTPFieldContentTypes.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPFieldContentTypes : MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var cases:[String:[String]] = [:]
        var raw_values:[String:[String]] = [:]
        for argument in node.arguments!.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                parse_and_insert(child.expression, cases: &cases, category: child.label!.text, raw_values: &raw_values)
            }
        }
        var decls:[DeclSyntax] = []
        for (key, values) in cases {
            var cases_string:String = ""
            var inits_string:String = "public static func parse(_ rawValue: String) -> HTTPMediaType? {\nswitch rawValue {"
            for i in 0..<values.count {
                let case_name:String = values[i]
                cases_string += (i == 0 ? "" : "\n") + "public static let \(case_name):HTTPMediaType = HTTPMediaType(rawValue: \"\(raw_values[key]![i])\", caseName: \"\(case_name)\", debugDescription: \"\("HTTPMediaType.\(key.capitalized).\(case_name)")\")"
                inits_string += "\ncase \"\(case_name)\", \"\(raw_values[key]![i])\": return \(case_name)"
            }
            inits_string += "\ndefault: return nil\n}\n}"

            var string:String = "// MARK: \(key.capitalized)\npublic enum \(key.capitalized) {\n"
            string += cases_string + "\n\n" + inits_string + "\n}"
            decls.append("\(raw: string)")
        }
        let parse:String = """
        public static func parse(_ string: String) -> HTTPMediaType? {
            if let media:HTTPMediaType = HTTPMediaType.Application.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Font.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Haptics.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Image.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Message.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Model.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Multipart.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Text.parse(string) {
                return media
            }
            if let media:HTTPMediaType = HTTPMediaType.Video.parse(string) {
                return media
            }
            return nil
            // TODO: report this bug | uncommenting the below completely breaks compilation (it takes forever)
            /*return HTTPMediaType.Application.parse(string)
                //?? HTTPMediaType.Audio.parse(string)
                ?? HTTPMediaType.Font.parse(string)
                ?? HTTPMediaType.Haptics.parse(string)
                ?? HTTPMediaType.Image.parse(string)
                ?? HTTPMediaType.Message.parse(string)
                ?? HTTPMediaType.Model.parse(string)
                ?? HTTPMediaType.Multipart.parse(string)
                ?? HTTPMediaType.Text.parse(string)
                ?? HTTPMediaType.Video.parse(string)*/
        }
        """
        decls.append("\(raw: parse)")
        return decls
    }
    static func parse_and_insert(_ expression: ExprSyntax, cases: inout [String:[String]], category: String, raw_values: inout [String:[String]]) {
        guard let dictionary:DictionaryElementListSyntax = expression.dictionary?.content.as(DictionaryElementListSyntax.self) else { return }
        cases[category] = []
        raw_values[category] = []
        for element in dictionary {
            let key:String = element.key.stringLiteral!.string
            var value:String = element.value.stringLiteral!.string
            if value.isEmpty {
                value = key
            }
            cases[category]!.append(key)
            raw_values[category]!.append(category + "/" + value)
        }
    }
}