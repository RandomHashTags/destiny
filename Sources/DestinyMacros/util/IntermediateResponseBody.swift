
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
        context: some MacroExpansionContext,
        isCopyable: Bool,
        responseString: inout String
    ) -> String {
        let prefix = isCopyable ? "" : "NonCopyable"
        switch type {
        case .bytes:
            return "\(prefix)Bytes(\(bytesPayload(context: context, responseString: &responseString)))"
        case .inlineBytes:
            return "\(prefix)InlineBytes(\(bytesPayload(context: context, responseString: &responseString)))"
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
            return "NonCopyableBytes(\(bytesPayload(context: context, responseString: &responseString)))"
        case .nonCopyableInlineBytes:
            return "NonCopyableInlineBytes(\(bytesPayload(context: context, responseString: &responseString)))"
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

    private func bytesPayload(
        context: some MacroExpansionContext,
        responseString: inout String
    ) -> [UInt8] {
        var payload = [UInt8]()
        payload.reserveCapacity(responseString.count)
        responseString.withUTF8 {
            payload.append(contentsOf: $0)
        }
        if let elements = valueExpr.array?.elements {
            for element in elements {
                if let s = element.expression.integerLiteral?.literal.text, let byte = UInt8(s) {
                    payload.append(byte)
                } else if let s = element.expression.memberAccess?.declName.baseName.text, let byte = UInt8(convenientName: s) {
                    payload.append(byte)
                } else {
                    context.diagnose(DiagnosticMsg.unhandled(node: element.expression))
                }
            }
        } else {
            context.diagnose(DiagnosticMsg.unhandled(node: valueExpr))
        }
        return payload
    }
}

extension IntermediateResponseBody {
    #if hasFeature(Embedded) || EMBEDDED
    public func responderDebugDescription<B>(
        context: some MacroExpansionContext,
        isCopyable: Bool,
        response: HTTPResponseMessage<B>
    ) -> String {
        let escapeLineBreak = !(type == .bytes || type == .nonCopyableBytes || type == .inlineBytes || type == .nonCopyableInlineBytes)
        var responseString = response.intermediateString(escapeLineBreak: escapeLineBreak)
        return responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
    }
    #else
    public func responderDebugDescription(
        context: some MacroExpansionContext,
        isCopyable: Bool,
        response: HTTPResponseMessage
    ) -> String {
        let escapeLineBreak = !(type == .bytes || type == .nonCopyableBytes || type == .inlineBytes || type == .nonCopyableInlineBytes)
        var responseString = response.intermediateString(escapeLineBreak: escapeLineBreak)
        return responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
    }
    #endif
}

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

extension IntermediateResponseBodyType {
    public var isEnabled: Bool? {
        switch self {
        case .bytes:
            #if CopyableBytes
            true
            #else
            false
            #endif
        case .inlineBytes:
            #if CopyableInlineBytes
            true
            #else
            false
            #endif
        case .macroExpansion:
            #if CopyableMacroExpansion
            true
            #else
            false
            #endif
        case .macroExpansionWithDateHeader:
            #if CopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .streamWithDateHeader:
            #if CopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .staticString:
            true
        case .staticStringWithDateHeader:
            #if CopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        case .stringWithDateHeader:
            #if CopyableStringWithDateHeader
            true
            #else
            false
            #endif

        case .string:
            #if StringRouteResponder
            true
            #else
            false
            #endif

        case .nonCopyableBytes:
            #if NonCopyableBytes
            true
            #else
            false
            #endif
        case .nonCopyableInlineBytes:
            #if NonCopyableInlineBytes
            true
            #else
            false
            #endif
        case .nonCopyableMacroExpansionWithDateHeader:
            #if NonCopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStreamWithDateHeader:
            #if NonCopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStaticStringWithDateHeader:
            #if NonCopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        }
    }
}

// MARK: UInt8 init
extension UInt8 {
    public init?(convenientName: String) {
        switch convenientName {
        case "lineFeed": self = .lineFeed
        case "carriageReturn": self = .carriageReturn
        case "space": self = .space
        case "exclamationMark": self = .exclamationMark
        case "quotation": self = .quotation
        case "numberSign": self = .numberSign
        case "dollarSign": self = .dollarSign
        case "percent": self = .percent
        case "ampersand": self = .ampersand
        case "apostrophe": self = .apostrophe
        case "openingParenthesis": self = .openingParenthesis
        case "closingParenthesis": self = .closingParenthesis
        case "asterisk": self = .asterisk
        case "plus": self = .plus
        case "comma": self = .comma
        case "subtract": self = .subtract
        case "period": self = .period
        case "forwardSlash": self = .forwardSlash
        case "colon": self = .colon
        case "semicolon": self = .semicolon
        case "lessThan": self = .lessThan
        case "equal": self = .equal
        case "greaterThan": self = .greaterThan
        case "questionMark": self = .questionMark
        case "atSign": self = .atSign
        case "openingBracket": self = .openingBracket
        case "backslash": self = .backslash
        case "closingBracket": self = .closingBracket
        case "caret": self = .caret
        case "underscore": self = .underscore
        case "graveAccent": self = .graveAccent
        case "openingBrace": self = .openingBrace
        case "verticalBar": self = .verticalBar
        case "closingBrace": self = .closingBrace
        case "tilde": self = .tilde
        case "euroSign": self = .euroSign
        case "poundSign": self = .poundSign
        case "zero": self = .zero
        case "one": self = .one
        case "two": self = .two
        case "three": self = .three
        case "four": self = .four
        case "five": self = .five
        case "six": self = .six
        case "seven": self = .seven
        case "eight": self = .eight
        case "nine": self = .nine
        case "A": self = .A
        case "B": self = .B
        case "C": self = .C
        case "D": self = .D
        case "E": self = .E
        case "F": self = .F
        case "G": self = .G
        case "H": self = .H
        case "I": self = .I
        case "J": self = .J
        case "K": self = .K
        case "L": self = .L
        case "M": self = .M
        case "N": self = .N
        case "O": self = .O
        case "P": self = .P
        case "Q": self = .Q
        case "R": self = .R
        case "S": self = .S
        case "T": self = .T
        case "U": self = .U
        case "V": self = .V
        case "W": self = .W
        case "X": self = .X
        case "Y": self = .Y
        case "Z": self = .Z
        case "a": self = .a
        case "b": self = .b
        case "c": self = .c
        case "d": self = .d
        case "e": self = .e
        case "f": self = .f
        case "g": self = .g
        case "h": self = .h
        case "i": self = .i
        case "j": self = .j
        case "k": self = .k
        case "l": self = .l
        case "m": self = .m
        case "n": self = .n
        case "o": self = .o
        case "p": self = .p
        case "q": self = .q
        case "r": self = .r
        case "s": self = .s
        case "t": self = .t
        case "u": self = .u
        case "v": self = .v
        case "w": self = .w
        case "x": self = .x
        case "y": self = .y
        case "z": self = .z
        default: return nil
        }
    }
}