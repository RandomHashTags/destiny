
import HTTPMediaTypes

extension HTTPMediaTypeFont: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "collection": self = .collection
        case "otf": self = .otf
        case "sfnt": self = .sfnt
        case "ttf": self = .ttf
        case "woff": self = .woff
        case "woff2": self = .woff2
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
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