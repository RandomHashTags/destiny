
import DestinyBlueprint

public enum HTTPMediaTypeAudio: HTTPMediaTypeProtocol {
    case aac
    case mp4
    case mpeg
    case ogg

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "audio"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .aac: "aac"
        case .mp4: "mp4"
        case .mpeg: "mpeg"
        case .ogg: "ogg"
        }
    }
}