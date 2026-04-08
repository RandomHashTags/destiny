
import Destiny
import SwiftSyntaxMacros

extension IntermediateResponseBody {
    private func preDateAndPostDateValues(_ string: String) -> (preDate: Substring, postDate: Substring) {
        let preDate = string[string.startIndex..<string.index(string.startIndex, offsetBy: 22)]
        let postDate = string[string.index(string.startIndex, offsetBy: 51)...]
        return (preDate, postDate)
    }

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
            if interpolation == 0 {
                // upgrade
                return IntermediateResponseBody(
                    valueExpr: valueExpr,
                    type: .staticStringWithDateHeader,
                    value: escapedValue(),
                    count: count,
                    interpolation: interpolation,
                    rawValue: rawValue,
                ).responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
            }
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            let (preDate, postDate) = preDateAndPostDateValues(responseString)
            return "StringWithDateHeader(preDateValue: \(delimiter)\"\(preDate)\"\(delimiter), postDateValue: \(delimiter)\"\(postDate)\"\(delimiter), value: \(delimiter)\"\(escapedValue())\"\(delimiter))"
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
    private func escapedValue() -> String {
        if let rawValue {
            var s = ""
            for b in rawValue {
                let hex = Self.byteToHex(b)
                s.append("\\u{\(hex.high)\(hex.low)}")
            }
            return s
        }
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
        var responseString = response.intermediateString(
                escapeLineBreak: escapeLineBreak,
                contentLength: count
            )
        return responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
    }
    #else
    public func responderDebugDescription(
        context: some MacroExpansionContext,
        isCopyable: Bool,
        response: HTTPResponseMessage
    ) -> String {
        let escapeLineBreak = !(type == .bytes || type == .nonCopyableBytes || type == .inlineBytes || type == .nonCopyableInlineBytes)
        var responseString = response.headString(
            escapeLineBreak: escapeLineBreak,
            contentLength: count
        )
        return responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
    }
    #endif
}

// MARK: Byte to hex
extension IntermediateResponseBody {
    private static let hexDigits:[16 of Character] = [
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "A",
        "B",
        "C",
        "D",
        "E",
        "F"
    ]
    private static func byteToHex(_ byte: UInt8) -> (high: Character, low: Character) {
        let high = PercentEncoding.hexDigits[unchecked: Int(byte >> 4)]
        let low = PercentEncoding.hexDigits[unchecked: Int(byte & 0x0F)]
        return (high, low)
    }
}