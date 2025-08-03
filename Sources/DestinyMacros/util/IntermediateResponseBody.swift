
import DestinyBlueprint
import DestinyDefaults

/// Sole purpose of this struct is to properly handle certain response bodies that aren't parsable with runtime data.
public struct IntermediateResponseBody: ResponseBodyProtocol {
    public let type:IntermediateResponseBodyType
    public let value:String

    @inlinable
    public init(
        type: IntermediateResponseBodyType,
        _ value: String
    ) {
        self.type = type
        self.value = value
    }

    @inlinable
    public var count: Int {
        value.count
    }

    @inlinable
    public func string() -> String {
        value
    }

    @inlinable public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {}

    public func responderDebugDescription(_ response: HTTPResponseMessage) throws -> String {
        let responseString = try response.intermediateString(escapeLineBreak: true)
        switch type {
        case .bytes:
            return "ResponseBody.Bytes(\(value))"
        case .inlineBytes:
            return "ResponseBody.InlineBytes(\(value))"
        case .macroExpansion:
            return "RouteResponses.MacroExpansion(\"\(responseString)\", body: \(value))"
        case .macroExpansionWithDateHeader:
            return "MacroExpansionWithDateHeader(\"\(responseString)\", body: \(value))"
        case .streamWithDateHeader:
            return "StreamWithDateHeader(\"\(responseString)\", body: \(value))"
        case .staticString:
            return "StaticString(\"\(responseString)\(escapedValue())\")"
        case .staticStringWithDateHeader:
            return "StaticStringWithDateHeader(\"\(responseString)\(escapedValue())\")"
        }
    }
    func escapedValue() -> String {
        var string = value
        string.replace("\"", with: "\\\"")
        return string
    }

    @inlinable
    public var hasDateHeader: Bool {
        switch type {
        case .macroExpansionWithDateHeader, .streamWithDateHeader, .staticStringWithDateHeader:
            return true
        default:
            return false
        }
    }

    @inlinable
    public var hasContentLength: Bool {
        return type != .streamWithDateHeader
    }
}

public enum IntermediateResponseBodyType: Sendable {
    case bytes
    case inlineBytes
    case macroExpansion
    case macroExpansionWithDateHeader
    case streamWithDateHeader
    case staticString
    case staticStringWithDateHeader
}

extension HTTPResponseMessage {
    @inlinable
    func intermediateString(escapeLineBreak: Bool) throws -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            if let contentType {
                string += "\(HTTPStandardResponseHeader.contentType.rawName): \(contentType)\((charset != nil ? "; charset=" + charset!.rawName : ""))\(suffix)"
            }
            if body.hasContentLength {
                let contentLength = body.string().utf8.count
                string += "\(HTTPStandardResponseHeader.contentLength.rawName): \(contentLength)\(suffix)\(suffix)"
            }
        }
        return string
    }
}