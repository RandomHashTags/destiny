
import DestinyBlueprint

public enum HTTPMediaTypeHaptics: HTTPMediaTypeProtocol {
    case ivs
    case hjif
    case hmpg

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "haptics"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .ivs: "ivs"
        case .hjif: "hjif"
        case .hmpg: "hmpg"
        }
    }
}