
#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#elseif canImport(Foundation)
import struct Foundation.Data
#endif

import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension ResponseBody {
    private static func parseString(_ expr: some ExprSyntaxProtocol) -> String {
        if let s = expr.stringLiteral?.string {
            return s
        } else {
            return expr.description
        }
    }
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> (any ResponseBodyProtocol)? {
        guard let function = expr.functionCall else {
            if let string = expr.stringLiteral?.string {
                return string
            }
            return nil
        }
        guard let firstArg = function.arguments.first else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        switch key {
        case "streamwithdateheader":
            return IntermediateResponseBody(type: .streamWithDateHeader, firstArg.expression.description)
        case "macroexpansion":
            return IntermediateResponseBody(type: .macroExpansion, firstArg.expression.description)
        case "macroexpansionwithdateheader":
            return IntermediateResponseBody(type: .macroExpansionWithDateHeader, firstArg.expression.description)
        case "string":
            return parseString(firstArg.expression)
        case "stringwithdateheader":
            return StringWithDateHeader(parseString(firstArg.expression))
        case "staticstring":
            return IntermediateResponseBody(type: .staticString, parseString(firstArg.expression))
        case "staticstringwithdateheader":
            return IntermediateResponseBody(type: .staticStringWithDateHeader, parseString(firstArg.expression))
        case "json":
            return nil // TODO: fix
        case "bytes":
            return IntermediateResponseBody(type: .bytes, firstArg.expression.description)
        case "inlinebytes":
            return IntermediateResponseBody(type: .inlineBytes, firstArg.expression.description)
        case "bytes16":
            var bytes = [UInt16]()
            let expression = firstArg.expression
            if let initCall = expression.functionCall {
                let interp = "\(initCall.calledExpression)"
                if (interp == "[UInt16]" || interp == "Array<UInt16>"),
                        let member = initCall.arguments.first?.expression.memberAccess,
                        let string = member.base?.stringLiteral?.string {
                    switch member.declName.baseName.text {
                    case "utf16": bytes = [UInt16](string.utf16)
                    default: break
                    }
                }
            } else if let array:[UInt16] = expression.array?.elements.compactMap({
                guard let integer = $0.expression.integerLiteral?.literal.text else { return nil }
                return UInt16(integer)
            }) {
                bytes = array
            }
            //self = .bytes16(bytes)
            return nil
        case "error":
            return nil // TODO: fix
        default:
            return nil
        }
    }
}