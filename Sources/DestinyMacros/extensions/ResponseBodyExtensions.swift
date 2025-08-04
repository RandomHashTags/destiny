
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

// MARK: Bytes
extension ResponseBody.Bytes {
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