
public enum HTTPCookieFlag {
}

// MARK: SameSite
extension HTTPCookieFlag {
    public enum SameSite: String, Sendable {
        case strict
        case lax
        case none

        @inlinable
        public var httpValue: String {
            switch self {
            case .strict: return "Strict"
            case .lax: return "Lax"
            case .none: return "None"
            }
        }
    }
}