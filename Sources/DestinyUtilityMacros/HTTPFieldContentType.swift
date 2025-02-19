//
//  HTTPFieldContentType.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPFieldContentType : DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var cases:[String] = []
        var httpValues:[String] = []
        var fileExtensions:[String:String] = [:]
        var category:String = ""
        for argument in node.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                switch child.label!.text {
                    case "category": category = child.expression.stringLiteral!.string
                    case "values": parse_and_insert(category: category, expr: child.expression, cases: &cases, httpValues: &httpValues, fileExtensions: &fileExtensions)
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

        var fileExtensionString:String = "        // MARK: Init File Extension\n        public init?(fileExtension: String) {\n            switch fileExtension {"
        for (fileExtension, targetCase) in fileExtensions {
            fileExtensionString += "\ncase \"\(fileExtension)\": self = .\(targetCase)"
        }
        fileExtensionString += "\ndefault: return nil\n}\n        }\n"
        decls.append("\(raw: "public enum \(categoryCapitalized) : String, HTTPMediaTypeProtocol {\n")")
        decls.append("\(raw: cases_string)")
        decls.append("\(raw: fileExtensionString)")
        decls.append("\(raw: debugDescriptions)")
        decls.append("\(raw: httpValuesString)")
        decls.append("\(raw: "\n    }")")
        return decls
    }
    static func parse_and_insert(
        category: String,
        expr: ExprSyntax,
        cases: inout [String],
        httpValues: inout [String],
        fileExtensions: inout [String:String]
    ) {
        guard let dictionary:DictionaryElementListSyntax = expr.dictionary?.content.as(DictionaryElementListSyntax.self) else { return }
        httpValues = []
        for element in dictionary {
            let key:String = element.key.stringLiteral!.string
            let value:HTTPFieldContentTypeDetails = HTTPFieldContentTypeDetails(key: key, expr: element.value.functionCall!)
            cases.append(key)
            httpValues.append(category + "/" + value.httpValue)
            for ext in value.fileExtensions {
                fileExtensions[ext] = key
            }
        }
    }
}

// MARK: HTTPFieldContentTypeDetails
struct HTTPFieldContentTypeDetails {
    let httpValue:String
    let fileExtensions:Set<String>
    
    init(key: String, expr: FunctionCallExprSyntax) {
        let value:String = expr.arguments.first!.expression.stringLiteral!.string
        httpValue = value.isEmpty ? key : value
        if let array:ArrayElementListSyntax = expr.arguments.last!.expression.array?.elements {
            fileExtensions = Set(array.compactMap({ $0.expression.stringLiteral?.string }))
        } else {
            fileExtensions = []
        }
    }
}
#endif