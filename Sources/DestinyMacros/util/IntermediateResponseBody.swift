
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax

/// Sole purpose of this struct is to properly handle certain response bodies that aren't parsable with runtime data.
public struct IntermediateResponseBody: ResponseBodyProtocol {
    public let type:IntermediateResponseBodyType
    public let valueExpr:ExprSyntax

    public init(
        type: IntermediateResponseBodyType,
        _ value: some ExprSyntaxProtocol
    ) {
        self.type = type
        self.valueExpr = .init(value)
    }

    var value: String {
        if let stringLiteral = valueExpr.stringLiteral {
            return stringLiteral.segments.map({
                if case let .stringSegment(seg) = $0 {
                    return seg.content.text.replacing("\n", with: "\\n")
                }
                return "\($0)"
            }).joined()
        }
        return valueExpr.description
    }

    public var count: Int {
        var c = value.count
        if let l = valueExpr.stringLiteral?.segments.count {
            c -= (l - 1)
        }
        return c
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
            var (preDate, postDate) = preDateAndPostDateValues("\(responseString)")
            postDate.removeLast(8 + String(value.count).count) // "#\r\n\r\n".count
            return "\(prefix)MacroExpansionWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\", body: \(value))"
        case .streamWithDateHeader:
            var (preDate, postDate) = preDateAndPostDateValues(responseString)
            postDate = "\\r\\nTransfer-Encoding: chunked\(postDate)"
            return "\(prefix)StreamWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\\r\\n\", body: \(value))"
        case .stringWithDateHeader:
            let (preDate, postDate) = preDateAndPostDateValues("\(responseString)")
            return "\(prefix)StringWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\", value: \"\(escapedValue())\")"
        case .staticString:
            return "\(prefix)StaticString(\"\(responseString)\(escapedValue())\")"
        case .staticStringWithDateHeader:
            let (preDate, postDate) = preDateAndPostDateValues("\(responseString)\(escapedValue())")
            return "\(prefix)StaticStringWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\")"

        case .string:
            return value

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
            let (preDate, postDate) = preDateAndPostDateValues("\(responseString)\(escapedValue())")
            return "NonCopyableStaticStringWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\")"
        }
    }
    func escapedValue() -> String {
        var string = value
        string.replace("\"", with: "\\\"")
        return string
    }
}

#if canImport(DestinyDefaultsNonEmbedded)

import DestinyDefaultsNonEmbedded

extension IntermediateResponseBody {
    public func responderDebugDescription(
        isCopyable: Bool,
        response: HTTPResponseMessage
    ) -> String {
        var responseString = response.intermediateString(escapeLineBreak: true)
        return responderDebugDescription(isCopyable: isCopyable, responseString: &responseString)
    }
}
#endif

#if GenericHTTPMessage

extension IntermediateResponseBody {
    public func responderDebugDescription<B, C>(
        isCopyable: Bool,
        response: GenericHTTPResponseMessage<B, C>
    ) -> String {
        var responseString = response.intermediateString(escapeLineBreak: true)
        return responderDebugDescription(isCopyable: isCopyable, responseString: &responseString)
    }
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