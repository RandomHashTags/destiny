
public enum HTTPCookieFlag {
}

// MARK: SameSite
extension HTTPCookieFlag {
    public enum SameSite: Sendable {
        case strict
        case lax
        case none

        #if Inlinable
        @inlinable
        #endif
        public var httpValue: String {
            switch self {
            case .strict: "Strict"
            case .lax:    "Lax"
            case .none:   "None"
            }
        }
    }
}