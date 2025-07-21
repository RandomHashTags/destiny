
#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#elseif canImport(Foundation)
import struct Foundation.Data
#endif

import DestinyBlueprint

public enum ResponseBody {
}

#if canImport(SwiftSyntax)
import SwiftSyntax

extension ResponseBody {
    private static func parseString(_ expr: ExprSyntax) -> Swift.String {
        if let s = expr.stringLiteral?.string {
            return s
        } else {
            return expr.description
        }
    }
    public static func parse(expr: ExprSyntax) -> (any ResponseBodyProtocol)? {
        guard let function = expr.functionCall else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        switch key {
#if canImport(FoundationEssentials) || canImport(Foundation)
        case "data": // TODO: fix
            return Data(
                function.arguments.first!.expression.array!.elements.compactMap({
                    guard let s = $0.expression.integerLiteral?.literal.text else { return nil }
                    return UInt8(s)
                })
            )
#endif
        case "macroexpansion":
            return ResponseBody.macroExpansion(function.arguments.first!.expression.description)
        case "macroexpansionwithdateheader":
            return ResponseBody.macroExpansionWithDateHeader(function.arguments.first!.expression.description)
        case "string":
            return parseString(function.arguments.first!.expression)
        case "stringwithdateheader":
            return StringWithDateHeader(parseString(function.arguments.first!.expression))
        case "json":
            return nil // TODO: fix
        case "bytes":
            var bytes:[UInt8] = []
            if let expression = function.arguments.first?.expression {
                if let initCall = expression.functionCall {
                    let interp = "\(initCall.calledExpression)"
                    if (interp == "[UInt8]" || interp == "Array<UInt8>"),
                            let member = initCall.arguments.first?.expression.memberAccess,
                            let string = member.base?.stringLiteral?.string {
                        switch member.declName.baseName.text {
                        case "utf8": bytes = [UInt8](string.utf8)
                        //case "utf16": bytes = [UInt16](string.utf16)
                        default: break
                        }
                    }
                } else if let array:[UInt8] = expression.array?.elements.compactMap({
                    guard let integer = $0.expression.integerLiteral?.literal.text else { return nil }
                    return UInt8(integer)
                }) {
                    bytes = array
                }
            }
            return ResponseBody.bytes(bytes)
        case "bytes16":
            var bytes:[UInt16] = []
            if let expression = function.arguments.first?.expression {
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
#endif