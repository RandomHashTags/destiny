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
        var cases_string:String = ""
        
        var decls:[DeclSyntax] = []
        for (index, var value) in cases.enumerated() {
            value = value[value.startIndex].uppercased() + value[value.index(after: value.startIndex)...]
            cases_string += "    public static let \(category)\(value) = get(.\(category), name: \"\(httpValues[index])\")\n"
        }

        var fileExtensionString:String = "        // MARK: Init File Extension\n        public init?(fileExtension: String) {\n            switch fileExtension {"
        for (fileExtension, targetCase) in fileExtensions {
            fileExtensionString += "\ncase \"\(fileExtension)\": self = .\(targetCase)"
        }
        fileExtensionString += "\ndefault: return nil\n}\n        }\n"
        decls.append("\(raw: cases_string)")
        //decls.append("\(raw: fileExtensionString)")
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
            httpValues.append(value.httpValue)
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
        if let array:ArrayElementListSyntax = expr.arguments.last?.expression.array?.elements {
            fileExtensions = Set(array.compactMap({ $0.expression.stringLiteral?.string }))
        } else {
            fileExtensions = []
        }
    }
}
#endif