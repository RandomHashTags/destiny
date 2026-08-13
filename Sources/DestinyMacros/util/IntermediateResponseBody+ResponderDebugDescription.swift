
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

        case .string(let isNonCopyable, let isStatic, let withDateHeader, let withCompressedBody):
            let delimiter = valueExpr.stringLiteral?.openingPounds?.text ?? ""
            var (preDate, postDate):(Substring, Substring)
            var trailingSuffix:Substring = ""
            var targetType:String
            if isStatic || interpolation == 0 {
                targetType = "StaticString"
                (preDate, postDate) = preDateAndPostDateValues("\(responseString)\(escapedValue())")
            } else {
                targetType = "String"
                (preDate, postDate) = preDateAndPostDateValues(responseString)
            }
            if withDateHeader {
                targetType += "WithDateHeader"
            }
            if !postDate.hasSuffix(delimiter) {
                postDate += delimiter
            }
            if withCompressedBody {
                targetType += "AndCompressedBody"
                (preDate, postDate) = preDateAndPostDateValues(responseString)
                trailingSuffix = ", body: \(rawValue ?? [])"
            }
            return "\(isNonCopyable ? "NonCopyable" : prefix)\(targetType)(preDateValue: \(delimiter)\"\(preDate)\"\(delimiter), postDateValue: \(delimiter)\"\(postDate)\"\(delimiter)\(trailingSuffix))"
        }
    }
    private func escapedValue() -> String {
        if let rawValue {
            var s = ""
            for b in rawValue {
                let hex = Self.byteToHex(b)
                s.append("\\u{\(hex.high)\(hex.low)}") // TODO: fix | bytes > 127 get encoded as two bytes
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
        let contentLength:Int
        let escapeLineBreak:Bool
        if type == .bytes || type == .nonCopyableBytes || type == .inlineBytes || type == .nonCopyableInlineBytes {
            escapeLineBreak = false
            contentLength = valueExpr.arrayElements(context: context)?.count ?? count
        } else {
            escapeLineBreak = true
            contentLength = count
        }
        var responseString = response.intermediateString(
            escapeLineBreak: escapeLineBreak,
            contentLength: contentLength
        )
        return responderDebugDescription(context: context, isCopyable: isCopyable, responseString: &responseString)
    }
    #else
    public func responderDebugDescription(
        context: some MacroExpansionContext,
        isCopyable: Bool,
        response: HTTPResponseMessage
    ) -> String {
        let contentLength:Int
        let escapeLineBreak:Bool
        if type == .bytes || type == .nonCopyableBytes || type == .inlineBytes || type == .nonCopyableInlineBytes {
            escapeLineBreak = false
            contentLength = valueExpr.arrayElements(context: context)?.count ?? count
        } else {
            escapeLineBreak = true
            contentLength = count
        }
        var responseString = response.headString(
            escapeLineBreak: escapeLineBreak,
            contentLength: contentLength
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
        let high = hexDigits[unchecked: Int(byte >> 4)]
        let low = hexDigits[unchecked: Int(byte & 0x0F)]
        return (high, low)
    }
}