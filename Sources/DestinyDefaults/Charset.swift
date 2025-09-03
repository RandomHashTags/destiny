
// MARK: Charset
/// HTTP charset encodings.
public enum Charset: String, Sendable {
    case any
    case basicMultilingualPlane
    case bocu1
    case iso8859_5
    case scsu
    case ucs2
    case ucs4
    case utf8
    case utf16
    case utf16be
    case utf16le
    case utf32

    // MARK: Raw name
    #if Inlinable
    @inlinable
    #endif
    public var rawName: String {
        switch self {
        case .any: "*"
        case .basicMultilingualPlane: "BMP"
        case .bocu1: "BOCU-1"
        case .iso8859_5: "ISO-8859-5"
        case .scsu: "SCSU"
        case .ucs2: "UCS-2"
        case .ucs4: "UCS-4"
        case .utf8: "UTF-8"
        case .utf16: "UTF-16"
        case .utf16be: "UTF-16BE"
        case .utf16le: "UTF-16LE"
        case .utf32: "UTF-32"
        }
    }
}