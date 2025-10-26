
#if HTTPCookie

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
        switch self {
        case .strict: "strict"
        case .lax: "lax"
        case .none: "none"
        }
    }
}

#endif