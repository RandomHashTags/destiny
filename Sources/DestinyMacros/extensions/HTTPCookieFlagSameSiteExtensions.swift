
import DestinyBlueprint

extension HTTPCookieFlag.SameSite: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "strict": self = .strict
        case "lax": self = .lax
        case "none": self = .none
        default: return nil
        }
    }

    public var rawValue: String {
        let s = "\(self)"
        return String(s[s.index(after: s.firstIndex(of: ".")!)...])
    }
}