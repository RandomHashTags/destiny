
#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPRequestMethods: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var entries = [Entry]()
        for argument in node.arguments {
            guard let array = argument.expression.array else { break }
            for element in array.elements {
                if let tuple = element.expression.as(TupleExprSyntax.self)?.elements {
                    var memberName = ""
                    var method = ""
                    for i in 0..<2 {
                        let index = tuple.index(at: i)
                        switch i {
                        case 0: memberName = tuple[tuple.startIndex].expression.stringLiteral!.string
                        case 1: method = tuple[index].expression.stringLiteral!.string
                        default: break
                        }
                    }
                    entries.append(getEntry(memberName: memberName, method: method))
                }
            }
        }
        var string = entries.map {
            "public static let \($0.memberName) = \($0.value)"
        }.joined(separator: "\n    ")

        string += "\n\n    public static func parse<T: ExprSyntaxProtocol>(expr: T) -> (any HTTPRequestMethodProtocol)? {\n"
        string += "        guard let string = expr.memberAccess?.declName.baseName.text ?? expr.stringLiteral?.string.lowercased() else { return nil }\n"
        string += "        switch string {\n"
        for entry in entries {
            var cases = [
                entry.memberName,
                entry.memberName.uppercased()
            ]
            if entry.memberName.first == "`" {
                var s = entry.memberName
                s = String(s[s.index(after: s.startIndex)..<s.index(before: s.endIndex)])
                cases.append(s)
                cases.append(s.uppercased())
            }
            let casesString = cases.map({ "\"\($0)\"" }).joined(separator: ", ")
            string += "        case \(casesString): return HTTPRequestMethod.\(entry.memberName)\n"
        }
        string += "        default: return nil\n"
        string += "        }\n    }"
        return ["\(raw: string)"]
    }

    static func getEntry(
        memberName: String,
        method: String
    ) -> HTTPRequestMethods.Entry {
        let valueArray:[String] = method.compactMap({
            guard let v = $0.asciiValue else { return nil }
            return String(v)
        })
        let value = "HTTPRequestMethod.Storage([\(valueArray.joined(separator: ", "))])"
        return Entry(memberName: memberName, method: method, count: valueArray.count, value: value)
    }
}

extension HTTPRequestMethods {
    struct Entry {
        let memberName:String
        let method:String
        let count:Int
        let value:String
    }
}

#endif