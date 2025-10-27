
import DestinyBlueprint
import DestinyDefaults

// MARK: String
extension String {
    func responderDebugDescription(_ input: String) -> String {
        "\"\(input)\""
    }

    func responderDebugDescription(_ input: some HTTPMessageProtocol) throws(HTTPMessageError) -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}

#if CopyableBytes
// MARK: Bytes
extension Bytes: CustomStringConvertible {
    public var description: String {
        "Bytes(\(value))"
    }

    var responderDebugDescription: Swift.String {
        description
    }

    func responderDebugDescription(_ input: String) -> String {
        "\(Self([UInt8](input.utf8)))"
    }

    func responderDebugDescription(_ input: some HTTPMessageProtocol) throws(HTTPMessageError) -> String {
        try responderDebugDescription(input.string(escapeLineBreak: false))
    }
}
#endif

#if CopyableInlineBytes
// MARK: InlineBytes
extension InlineBytes: CustomStringConvertible {
    public var description: String {
        "InlineBytes(\(value))" // TODO: fix
    }
}
#endif

#if CopyableStringWithDateHeader
// MARK: StringWithDateHeader
extension StringWithDateHeader {
    var responderDebugDescription: String {
        "StringWithDateHeader(\"\(value)\")"
    }

    func responderDebugDescription(_ input: String) -> String {
        Self(input).responderDebugDescription
    }

    func responderDebugDescription(_ input: some HTTPMessageProtocol) throws(HTTPMessageError) -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }
}
#endif