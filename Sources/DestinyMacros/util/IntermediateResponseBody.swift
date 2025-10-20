
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

/// Sole purpose of this struct is to properly handle certain response bodies that aren't parsable with runtime data.
public struct IntermediateResponseBody: ResponseBodyProtocol {
    public let valueExpr:ExprSyntax
    public let type:IntermediateResponseBodyType
    let value:String
    public let count:Int

    public init(
        type: IntermediateResponseBodyType,
        _ valueExpr: ExprSyntax
    ) {
        self.type = type
        self.valueExpr = valueExpr

        let valueString:String
        var count = 0
        if let stringLiteral = valueExpr.stringLiteral {
            count = (stringLiteral.segments.count - 1)
            valueString = Self.upgradeSegments(stringLiteral.segments)
        } else {
            valueString = valueExpr.description
        }
        self.value = valueString
        self.count = valueString.count - count
    }

    private static func upgradeSegments(_ list: StringLiteralSegmentListSyntax) -> String {
        return list.map({
            switch $0 {
            case .stringSegment(let seg):
                return upgradeStringSegment(seg)
            case .expressionSegment(let seg):
                return upgradeExpressionSegment(seg)
            }
        }).joined()
    }
    private static func upgradeStringSegment(_ segment: StringSegmentSyntax) -> String {
        return segment.content.text.replacing("\n", with: "\\n")
    }
    private static func upgradeExpressionSegment(_ segment: ExpressionSegmentSyntax) -> String {
        // remove interpolation where it doesn't need it
        return segment.expressions.map({
            if let s = $0.expression.stringLiteral {
                return upgradeSegments(s.segments)
            }
            return $0.expression.booleanLiteral?.literal.text
                ?? $0.expression.integerLiteral?.literal.text
                ?? $0.expression.as(FloatLiteralExprSyntax.self)?.literal.text
                ?? $0.description
        }).joined()
    }

    public func string() -> String {
        value
    }

    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
    }

    private func preDateAndPostDateValues(_ string: String) -> (preDate: Substring, postDate: Substring) {
        let preDate = string[string.startIndex..<string.index(string.startIndex, offsetBy: 22)]
        let postDate = string[string.index(string.startIndex, offsetBy: 51)...]
        return (preDate, postDate)
    }

    var isNoncopyable: Bool {
        switch type {
        case .bytes,
            .inlineBytes,
            .macroExpansion,
            .macroExpansionWithDateHeader,
            .stringWithDateHeader,
            .staticString,
            .staticStringWithDateHeader,
            .streamWithDateHeader,
            .nonCopyableBytes,
            .nonCopyableInlineBytes,
            .nonCopyableMacroExpansionWithDateHeader,
            .nonCopyableStaticStringWithDateHeader,
            .nonCopyableStreamWithDateHeader:
            true
        default:
            false
        }
    }

    public var hasDateHeader: Bool {
        switch type {
        case .macroExpansionWithDateHeader,
            .streamWithDateHeader,
            .staticStringWithDateHeader,
            .stringWithDateHeader,
            .nonCopyableMacroExpansionWithDateHeader,
            .nonCopyableStaticStringWithDateHeader,
            .nonCopyableStreamWithDateHeader:
            true
        default:
            false
        }
    }

    public var hasContentLength: Bool {
        switch type {
        case .streamWithDateHeader, .nonCopyableStreamWithDateHeader:
            false
        default:
            true
        }
    }
}

// MARK: Parse
extension IntermediateResponseBody {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> IntermediateResponseBody? {
        guard let function = expr.functionCall else {
            if let string = expr.stringLiteral {
                if string.segments.firstIndex(where: { $0.is(ExpressionSegmentSyntax.self) }) == nil {
                    // can be upgraded to a `StaticString`
                    return Self(type: .staticString, .init(expr))
                }
                return Self(type: .string, .init(expr))
            }
            return nil
        }
        guard let firstArg = function.arguments.first else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        if let key, let type = IntermediateResponseBodyType(rawValue: key) {
            return Self(type: type, firstArg.expression)
        }
        context.diagnose(DiagnosticMsg.unhandled(node: expr))
        return nil
    }
}

// MARK: Responder debug description
extension IntermediateResponseBody {
    func responderDebugDescription(
        isCopyable: Bool,
        responseString: inout String
    ) -> String {
        let prefix = isCopyable ? "" : "NonCopyable"
        switch type {
        case .bytes:
            return "ResponseBody.\(prefix)Bytes(\(value))"
        case .inlineBytes:
            return "ResponseBody.\(prefix)InlineBytes(\(value))"
        case .macroExpansion:
            responseString.removeLast(8 + String(value.count).count) // "#\r\n\r\n".count
            return "RouteResponses.\(prefix)MacroExpansion(\"\(responseString)\", body: \(value))"
        case .macroExpansionWithDateHeader:
            var (preDate, postDate) = preDateAndPostDateValues(responseString)
            postDate.removeLast(8 + String(value.count).count) // "#\r\n\r\n".count
            return "\(prefix)MacroExpansionWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\", body: \(value))"
        case .streamWithDateHeader:
            var (preDate, postDate) = preDateAndPostDateValues(responseString)
            postDate = "\\r\\nTransfer-Encoding: chunked\(postDate)"
            return "\(prefix)StreamWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\\r\\n\", body: \(value))"
        case .stringWithDateHeader:
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            let (preDate, postDate) = preDateAndPostDateValues(responseString)
            return "\(prefix)StringWithDateHeader(preDateValue: \(delimiter)\"\(preDate)\"\(delimiter), postDateValue: \(delimiter)\"\(postDate)\"\(delimiter), value: \(delimiter)\"\(escapedValue())\"\(delimiter))"
        case .staticString:
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            return "StaticString(\(delimiter)\"\(responseString)\(escapedValue())\"\(delimiter))"
        case .staticStringWithDateHeader:
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            let (preDate, postDate) = preDateAndPostDateValues("\(responseString)\(escapedValue())")
            return "\(prefix)StaticStringWithDateHeader(preDateValue: \(delimiter)\"\(preDate)\"\(delimiter), postDateValue: \(delimiter)\"\(postDate)\"\(delimiter))"

        case .string:
            var s = responseString + value
            if s.first != "\"" {
                s.insert("\"", at: s.startIndex)
            }
            if s.last != "\"" {
                s.append("\"")
            }
            if let stringLiteral = valueExpr.stringLiteral, let openingPounds = stringLiteral.openingPounds, let closingPounds = stringLiteral.closingPounds {
                s = openingPounds.text + s + closingPounds.text
            }
            return s

        case .nonCopyableBytes:
            return "ResponseBody.NonCopyableBytes(\(value))"
        case .nonCopyableInlineBytes:
            return "ResponseBody.NonCopyableInlineBytes(\(value))"
        case .nonCopyableMacroExpansionWithDateHeader:
            var (preDate, postDate) = preDateAndPostDateValues("\(responseString)")
            postDate.removeLast(8 + String(value.count).count) // "#\r\n\r\n".count
            return "NonCopyableMacroExpansionWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\", body: \(value))"
        case .nonCopyableStreamWithDateHeader:
            var (preDate, postDate) = preDateAndPostDateValues(responseString)
            postDate = "\\r\\nTransfer-Encoding: chunked\(postDate)"
            return "NonCopyableStreamWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\\r\\n\", body: \(value))"
        case .nonCopyableStaticStringWithDateHeader:
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            let (preDate, postDate) = preDateAndPostDateValues("\(responseString)\(escapedValue())")
            return "NonCopyableStaticStringWithDateHeader(preDateValue: \(delimiter)\"\(preDate)\"\(delimiter), postDateValue: \(delimiter)\"\(postDate)\"\(delimiter))"
        }
    }
    func escapedValue() -> String {
        var string = value
        guard valueExpr.stringLiteral?.openingPounds == nil else {
            // don't escape the string if it uses pound delimiters
            return string
        }
        string.replace("\"", with: "\\\"")
        return string
    }
}

#if canImport(DestinyDefaultsNonEmbedded)

import DestinyDefaultsNonEmbedded

extension IntermediateResponseBody {
    #if hasFeature(Embedded) || EMBEDDED
    public func responderDebugDescription<B>(
        isCopyable: Bool,
        response: HTTPResponseMessage<B>
    ) -> String {
        var responseString = response.intermediateString(escapeLineBreak: true)
        return responderDebugDescription(isCopyable: isCopyable, responseString: &responseString)
    }
    #else
    public func responderDebugDescription(
        isCopyable: Bool,
        response: HTTPResponseMessage
    ) -> String {
        var responseString = response.intermediateString(escapeLineBreak: true)
        return responderDebugDescription(isCopyable: isCopyable, responseString: &responseString)
    }
    #endif
}
#endif

// MARK: IntermediateResponseBodyType
public enum IntermediateResponseBodyType: String, Sendable {
    case bytes
    case inlineBytes                             = "inlinebytes"
    case macroExpansion                          = "macroexpansion"
    case macroExpansionWithDateHeader            = "macroexpansionwithdateheader"
    case streamWithDateHeader                    = "streamwithdateheader"
    case staticString                            = "staticstring"
    case staticStringWithDateHeader              = "staticstringwithdateheader"
    case stringWithDateHeader                    = "stringwithdateheader"

    case string

    case nonCopyableBytes                        = "noncopyablebytes"
    case nonCopyableInlineBytes                  = "noncopyableinlinebytes"
    case nonCopyableMacroExpansionWithDateHeader = "noncopyablemacroexpansionwithdateheader"
    case nonCopyableStreamWithDateHeader         = "noncopyablestreamwithdateheader"
    case nonCopyableStaticStringWithDateHeader   = "noncopyablestaticstringwithdateheader"
}