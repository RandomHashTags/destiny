
import DestinyBlueprint

public enum HTTPMediaTypeFont: String, HTTPMediaTypeProtocol {
    case collection
    case otf
    case sfnt
    case ttf
    case woff
    case woff2

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
        "font"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .collection: rawValue
        case .otf: rawValue
        case .sfnt: rawValue
        case .ttf: rawValue
        case .woff: rawValue
        case .woff2: rawValue
        }
    }
}