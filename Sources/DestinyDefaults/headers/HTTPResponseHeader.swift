
public enum HTTPResponseHeader {
}

// MARK: Accept-CH
/*
extension HTTPResponseHeader {
    public enum AcceptCH: String, Sendable {
        case experimental
    }
}*/

// MARK: Accept-Ranges
extension HTTPResponseHeader {
    public enum AcceptRanges: String, Sendable {
        case bytes
    }
}

// MARK: TK
extension HTTPResponseHeader {
    public enum TK: String, Sendable {
        case disregardingDNT
        case dynamic
        case gatewayToMultipleParties
        case notTracking
        case tracking
        case trackingOnlyIfConsented
        case trackingWithConsent
        case underConstruction
        case updated

        public var rawName: String {
            switch self {
            case .disregardingDNT: return "D"
            case .dynamic: return "?"
            case .gatewayToMultipleParties: return "G"
            case .notTracking: return "N"
            case .tracking: return "T"
            case .trackingOnlyIfConsented: return "P"
            case .trackingWithConsent: return "C"
            case .underConstruction: return "!"
            case .updated: return "U"
            }
        }
    }
}