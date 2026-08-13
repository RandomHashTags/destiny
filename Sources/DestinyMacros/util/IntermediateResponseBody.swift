
import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

/// Sole purpose of this struct is to properly handle certain response bodies that aren't parsable with runtime data.
public struct IntermediateResponseBody: ResponseBodyProtocol {
    public let valueExpr:ExprSyntax
    public var type:IntermediateResponseBodyType
    let value:String
    public private(set) var count:Int
    var interpolation = 0
    var rawValue:[UInt8]? = nil {
        didSet {
            count = rawValue?.count ?? count
        }
    }

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
            (valueString, interpolation) = Self.upgradeSegments(stringLiteral.segments)
        } else {
            valueString = valueExpr.description
        }
        self.value = valueString
        self.count = valueString.count - count
    }
    init(
        valueExpr: ExprSyntax,
        type: IntermediateResponseBodyType,
        value: String,
        count: Int,
        interpolation: Int,
        rawValue: [UInt8]? = nil
    ) {
        self.valueExpr = valueExpr
        self.type = type
        self.value = value
        self.count = rawValue?.count ?? count
        self.interpolation = interpolation
        self.rawValue = rawValue
    }

    public func string() -> String {
        value
    }

    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
    }

    var isNoncopyable: Bool {
        switch type {
        case .bytes,
            .inlineBytes,
            .macroExpansion,
            .macroExpansionWithDateHeader,
            .streamWithDateHeader,
            .nonCopyableBytes,
            .nonCopyableInlineBytes,
            .nonCopyableMacroExpansionWithDateHeader,
            .nonCopyableStreamWithDateHeader:
            true
        case .string(false, false, true, _),
            .string(false, true, _, _),
            .string(true, _, _, _):
            true
        default:
            false
        }
    }

    public var hasDateHeader: Bool {
        switch type {
        case .macroExpansionWithDateHeader,
            .streamWithDateHeader,
            .nonCopyableMacroExpansionWithDateHeader,
            .nonCopyableStreamWithDateHeader:
            true
        case .string(_, _, let withDateHeader, _):
            withDateHeader
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

// MARK: upgrade
extension IntermediateResponseBody {
    private static func upgradeSegments(_ list: StringLiteralSegmentListSyntax) -> (String, Int) {
        var interpolation = 0
        var s = ""
        for element in list {
            switch element {
            case .stringSegment(let seg):
                s += upgradeStringSegment(seg)
            case .expressionSegment(let seg):
                let result = upgradeExpressionSegment(seg)
                s += result.0
                interpolation += result.1
            }
        }
        return (s, interpolation)
    }
    private static func upgradeStringSegment(_ segment: StringSegmentSyntax) -> String {
        return segment.content.text.replacing("\n", with: "\\n")
    }
    private static func upgradeExpressionSegment(_ segment: ExpressionSegmentSyntax) -> (String, Int) {
        var interpolation = 0
        var s = ""
        // remove interpolation where it doesn't need it
        for element in segment.expressions {
            if let literal = element.expression.stringLiteral {
                let result = upgradeSegments(literal.segments)
                s += result.0
                interpolation += result.1
                break
            }
            if let v = element.expression.booleanLiteral?.literal.text
                    ?? element.expression.integerLiteral?.literal.text
                    ?? element.expression.as(FloatLiteralExprSyntax.self)?.literal.text {
                s += v
                break
            }
            s += element.description
            interpolation += 1
        }
        return (s, interpolation)
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
                    return Self(
                        type: .string(isNonCopyable: false, isStatic: true, withDateHeader: false, withCompressedBody: false),
                        .init(expr)
                    )
                }
                return Self(
                    type: .string(isNonCopyable: false, isStatic: false, withDateHeader: false, withCompressedBody: false),
                    .init(expr)
                )
            }
            return nil
        }
        guard let firstArg = function.arguments.first else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        if let key, let t = IntermediateResponseBodyType.parse(key: key, args: function.arguments) {
            return Self(type: t, firstArg.expression)
        }
        context.diagnose(DiagnosticMsg.unhandled(node: expr))
        return nil
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