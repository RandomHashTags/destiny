import DestinyBlueprint

public enum HTTPMediaTypeHaptics: String, HTTPMediaTypeProtocol {
    case ivs
    case hjif
    case hmpg

    @inlinable
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {

        default: return nil
        }
    }

    @inlinable
    public var type: String {
        "haptics"
    }

    @inlinable
    public var subType: String {
        switch self {
        case .ivs: rawValue
        case .hjif: rawValue
        case .hmpg: rawValue
        }
    }
}