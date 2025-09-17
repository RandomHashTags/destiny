
import HTTPMediaTypes

extension HTTPMediaTypeAudio {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "aac": self = .aac
        case "mp4": self = .mp4
        case "mpeg": self = .mpeg
        case "ogg": self = .ogg
        default: return nil
        }
    }
}