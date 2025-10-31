

extension Charset: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "any": self = .any
        case "basicMultilingualPlane": self = .basicMultilingualPlane
        case "bocu1": self = .bocu1
        case "iso8859_5": self = .iso8859_5
        case "scsu": self = .scsu
        case "ucs2": self = .ucs2
        case "ucs4": self = .ucs4
        case "utf8": self = .utf8
        case "utf16": self = .utf16
        case "utf16be": self = .utf16be
        case "utf16le": self = .utf16le
        case "utf32": self = .utf32
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .any: "any"
        case .basicMultilingualPlane: "basicMultilingualPlane"
        case .bocu1: "bocu1"
        case .iso8859_5: "iso8859_5"
        case .scsu: "scsu"
        case .ucs2: "ucs2"
        case .ucs4: "ucs4"
        case .utf8: "utf8"
        case .utf16: "utf16"
        case .utf16be: "utf16be"
        case .utf16le: "utf16le"
        case .utf32: "utf32"
        }
    }
}