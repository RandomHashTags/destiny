
import DestinyBlueprint

public enum HTTPMediaTypeFont: HTTPMediaTypeProtocol {
    case collection
    case otf
    case sfnt
    case ttf
    case woff
    case woff2

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
        case .collection: "collection"
        case .otf: "otf"
        case .sfnt: "sfnt"
        case .ttf: "ttf"
        case .woff: "woff"
        case .woff2: "woff2"
        }
    }
}