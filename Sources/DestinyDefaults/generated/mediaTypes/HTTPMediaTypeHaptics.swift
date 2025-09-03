
import DestinyBlueprint

public enum HTTPMediaTypeHaptics: String, HTTPMediaTypeProtocol {
    case ivs
    case hjif
    case hmpg

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {

        default: return nil
        }
    }

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
        case .ivs: rawValue
        case .hjif: rawValue
        case .hmpg: rawValue
        }
    }
}