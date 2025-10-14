
/// List of Hypertext Transfer Protocol versions.
public enum HTTPVersion: Hashable, Sendable {
    case v0_9
    case v1_0
    case v1_1
    case v1_2
    case v2_0
    case v3_0

    /// Tries to map the given token to the referenced `HTTPVersion`.
    /// 
    /// - Parameters:
    ///   - token: The `UInt64` in `bigEndian` representation.
    #if Inlinable
    @inlinable
    #endif
    public init?(token: UInt64) {
        switch token {
        case 5211883372140310073: self = .v0_9
        case 5211883372140375600: self = .v1_0
        case 5211883372140375601: self = .v1_1
        case 5211883372140375602: self = .v1_2
        case 5211883372140441136: self = .v2_0
        case 5211883372140506672: self = .v3_0
        default: return nil
        }
    }

    /// String representation of this HTTP Version (`HTTP/<major>.<minor>`).
    #if Inlinable
    @inlinable
    #endif
    public var string: String {
        switch self {
        case .v0_9: "HTTP/0.9"
        case .v1_0: "HTTP/1.0"
        case .v1_1: "HTTP/1.1"
        case .v1_2: "HTTP/1.2"
        case .v2_0: "HTTP/2.0"
        case .v3_0: "HTTP/3.0"
        }
    }

    /// StaticString representation of this HTTP Version (`HTTP/<major>.<minor>`).
    #if Inlinable
    @inlinable
    #endif
    public var staticString: StaticString {
        switch self {
        case .v0_9: "HTTP/0.9"
        case .v1_0: "HTTP/1.0"
        case .v1_1: "HTTP/1.1"
        case .v1_2: "HTTP/1.2"
        case .v2_0: "HTTP/2.0"
        case .v3_0: "HTTP/3.0"
        }
    }
}