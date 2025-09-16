
import DestinyDefaults

extension HTTPMediaTypeHaptics: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "ivs": self = .ivs
        case "hjif": self = .hjif
        case "hmpg": self = .hmpg
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .ivs: "ivs"
        case .hjif: "hjif"
        case .hmpg: "hmpg"
        }
    }
}