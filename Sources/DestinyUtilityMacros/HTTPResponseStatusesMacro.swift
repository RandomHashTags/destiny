
#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPResponseStatusesMacro: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var entries:[Entry] = []
        for argument in node.arguments {
            guard let array = argument.expression.array else { break }
            for element in array.elements {
                if let tuple = element.expression.as(TupleExprSyntax.self)?.elements {
                    var memberName = ""
                    var code:Int = 0
                    var phrase = ""
                    for i in 0..<3 {
                        let index = tuple.index(at: i)
                        switch i {
                        case 0: memberName = tuple[tuple.startIndex].expression.stringLiteral!.string
                        case 1: code = Int(tuple[index].expression.as(IntegerLiteralExprSyntax.self)!.literal.text)!
                        case 2: phrase = tuple[index].expression.stringLiteral!.string
                        default: break
                        }
                    }
                    entries.append(Entry(memberName: memberName, code: code, value: HTTPResponseStatusMacro.get(code: code, phrase: phrase)))
                }
            }
        }
        let string = entries.map {
            "/// https://www.rfc-editor.org/rfc/rfc9110.html#status.\($0.code)\n    public static let \($0.memberName) = \($0.value)"
        }.joined(separator: "\n    ")
        return ["\(raw: string)"]
    }
}

extension HTTPResponseStatusesMacro {
    struct Entry {
        let memberName:String
        let code:Int
        let value:String
    }
}

#endif