
import HTTPMediaTypes

extension HTTPMediaTypeImage {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "gif": self = .gif
        case "jpeg", "jpg": self = .jpeg
        case "png": self = .png
        default: return nil
        }
    }
}