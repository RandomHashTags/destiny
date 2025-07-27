
import DestinyBlueprint
import DestinyDefaults

// MARK: String
extension String {
    public func responderDebugDescription(_ input: String) -> String {
        "\"\(input)\""
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: StaticString
extension StaticString {
    public func responderDebugDescription(_ input: String) -> String {
        "\"\(input)\""
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: Foundation

#if canImport(FoundationEssentials) || canImport(Foundation)

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Data {
    public var debugDescription: String {
        "Data(\(self))"
    }

    public func responderDebugDescription(_ input: String) -> String {
        Self(Data(input.utf8)).debugDescription
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String{
        try responderDebugDescription(input.string(escapeLineBreak: false))
    }
}

#endif


// MARK: Bytes
extension ResponseBody.Bytes {
    public var responderDebugDescription: Swift.String {
        description
    }

    public func responderDebugDescription(_ input: String) -> String {
        "\(Self([UInt8](input.utf8)))"
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: false))
    }
}

// MARK: MacroExpansion
extension ResponseBody.MacroExpansion {
    public var responderDebugDescription: String {
        "RouteResponses.MacroExpansion(\"\(value))"
    }

    public func responderDebugDescription(_ input: String) -> String {
        ResponseBody.MacroExpansion<String>(input).responderDebugDescription
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: MacroExpansionWithDateHeader
extension ResponseBody.MacroExpansionWithDateHeader {
    public var responderDebugDescription: String {
        "MacroExpansionWithDateHeader(\"\(value))"
    }

    public func responderDebugDescription(_ input: String) -> String {
        ResponseBody.MacroExpansionWithDateHeader<String>(input).responderDebugDescription
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: StreamWithDateHeader
extension ResponseBody.StreamWithDateHeader {
    public var responderDebugDescription: String {
        "StreamWithDateHeader(\"\(value))"
    }

    public func responderDebugDescription(_ input: String) -> String {
        ResponseBody.StreamWithDateHeader<String>(input).responderDebugDescription
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: StaticStringWithDateHeader
extension StaticStringWithDateHeader {
    public var responderDebugDescription: String {
        "StaticStringWithDateHeader(\"\(value)\")"
    }

    public func responderDebugDescription(_ input: String) -> String {
        fatalError("cannot do that")
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

// MARK: StringWithDateHeader
extension StringWithDateHeader {
    public var responderDebugDescription: String {
        "StringWithDateHeader(\"\(value)\")"
    }

    public func responderDebugDescription(_ input: String) -> String {
        Self(input).responderDebugDescription
    }

    public func responderDebugDescription(_ input: some HTTPMessageProtocol) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}