
import DestinyDefaults

extension HTTPMediaTypeAudio: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "aac": self = .aac
        case "mp4": self = .mp4
        case "mpeg": self = .mpeg
        case "ogg": self = .ogg
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .aac: "aac"
        case .mp4: "mp4"
        case .mpeg: "mpeg"
        case .ogg: "ogg"
        }
    }
}