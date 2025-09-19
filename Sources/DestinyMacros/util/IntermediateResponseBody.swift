
import DestinyBlueprint
import DestinyDefaults

/// Sole purpose of this struct is to properly handle certain response bodies that aren't parsable with runtime data.
public struct IntermediateResponseBody: ResponseBodyProtocol {
    public let type:IntermediateResponseBodyType
    public let value:String

    public init(
        type: IntermediateResponseBodyType,
        _ value: String
    ) {
        self.type = type
        self.value = value
    }

    public var count: Int {
        value.count
    }

    public func string() -> String {
        value
    }

    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
    }

    public func responderDebugDescription(
        isCopyable: Bool,
        response: some AbstractHTTPMessageProtocol
    ) -> String {
        let prefix = isCopyable ? "" : "NonCopyable"
        var responseString = response.intermediateString(escapeLineBreak: true)
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
            return "StreamWithDateHeader(preDateValue: \"\(preDate)\", postDateValue: \"\(postDate)\\r\\n\", body: \(value))"
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

    private func preDateAndPostDateValues(_ string: String) -> (preDate: Substring, postDate: Substring) {
        let preDate = string[string.startIndex..<string.index(string.startIndex, offsetBy: 22)]
        let postDate = string[string.index(string.startIndex, offsetBy: 51)...]
        return (preDate, postDate)
    }

    var isNoncopyable: Bool {
        switch type {
        case .bytes, .inlineBytes, .macroExpansion, .macroExpansionWithDateHeader, .stringWithDateHeader, .staticString, .staticStringWithDateHeader,
                .nonCopyableBytes, .nonCopyableInlineBytes, .nonCopyableMacroExpansionWithDateHeader, .nonCopyableStaticStringWithDateHeader:
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
                .nonCopyableStaticStringWithDateHeader:
            return true
        default:
            return false
        }
    }

    public var hasContentLength: Bool {
        return type != .streamWithDateHeader
    }
}

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
    case nonCopyableStaticStringWithDateHeader   = "noncopyablestaticstringwithdateheader"
}