
import HTTPMediaTypes

extension HTTPMediaTypeVideo {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "av1": self = .av1
        case "mpeg": self = .mpeg
        case "ogg": self = .ogg
        default: return nil
        }
    }
}