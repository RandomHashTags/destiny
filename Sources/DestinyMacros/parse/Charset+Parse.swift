
import SwiftSyntax

extension Charset {
    public init?(expr: some ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text ?? expr.stringLiteral?.string.lowercased() else {
            return nil
        }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            switch string {
            case "bocu-1": self = .bocu1
            case "iso-8859-5": self = .iso8859_5
            case "ucs-2": self = .ucs2
            case "ucs-4": self = .ucs4
            case "utf-8": self = .utf8
            case "utf-16": self = .utf16
            case "utf-16be": self = .utf16be
            case "utf-16le": self  = .utf16le
            case "utf-32": self = .utf32
            default: return nil
            }
        }
    }
}