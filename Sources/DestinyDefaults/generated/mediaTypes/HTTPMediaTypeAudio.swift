import DestinyBlueprint

public enum HTTPMediaTypeAudio: String, HTTPMediaTypeProtocol {
    case aac
    case mp4
    case mpeg
    case ogg

    @inlinable
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "aac": self = .aac
        case "mp4": self = .mp4
        case "mpeg": self = .mpeg
        case "ogg": self = .ogg
        default: return nil
        }
    }

    @inlinable
    public var type: String {
        "audio"
    }

    @inlinable
    public var subType: String {
        switch self {
        case .aac: rawValue
        case .mp4: rawValue
        case .mpeg: rawValue
        case .ogg: rawValue
        }
    }
}